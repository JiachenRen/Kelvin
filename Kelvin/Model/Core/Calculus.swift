//
//  Calculus.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let calculusOperations: [Operation] = [
    .binary(.derivative, [.any, .var]) {
        let v = $1 as! Variable
        Scope.withholdAccess(to: v)
        let dv = Calculus.derivative(
            of: try $0.simplify(),
            withRespectTo: v)
        Scope.releaseRestrictions()
        return dv
    },
    .init(.derivative, [.any, .var, .number]) {
        let v = $0[1] as! Variable
        Scope.withholdAccess(to: v)
        let dnv = try Calculus.derivative(
            of: $0[0].simplify(),
            withRespectTo: v,
            try $0[2].simplify() as! Int)
        Scope.releaseRestrictions()
        return dnv
    },
    .init(.implicitDifferentiation, [.any, .var, .var]) {
        let dv = $0[1] as! Variable
        let iv = $0[2] as! Variable
        Scope.withholdAccess(to: dv, iv)
        guard let eq = try $0[0].simplify() as? Equation else {
            let msg = "left hand side of implicit differentiation must be an equation"
            throw ExecutionError.general(errMsg: msg)
        }
        let r = try Calculus.implicitDifferentiation(
            eq,
            dependentVar: dv,
            independentVar: iv)
        Scope.releaseRestrictions()
        return r
    },
    .binary(.gradient, [.func, .list]) {
        let vars = try ($1 as! List).elements.map {
            (n: Node) -> Variable in
            if let v = n as? Variable {
                return v
            }
            throw ExecutionError.incompatibleList(.variable)
        }
        
        Scope.withholdAccess(to: vars)
        let grad = Calculus.gradient(
            of: $0 as! Function,
            independentVars: vars)
        Scope.releaseRestrictions()
        return grad
    },
    .init(.directionalDifferentiation, [.func, .any, .list]) {
        let vars = try ($0[2] as! List).elements.map {
            (n: Node) -> Variable in
            if let v = n as? Variable {
                return v
            }
            throw ExecutionError.incompatibleList(.variable)
        }
        
        guard let dir = try $0[1].simplify() as? Vector else {
            throw ExecutionError.general(errMsg: "direction must be a vector")
        }
        
        Scope.withholdAccess(to: vars)
        let grad = try Calculus.directionalDifferentiation(
            of: $0[0] as! Function,
            direction: dir,
            independentVars: vars)
        Scope.releaseRestrictions()
        return grad
    }
]

public class Calculus {
    
    /**
     The directional derivative del _(u)f(x_0,y_0,z_0) is the rate at which the function f(x,y,z)
     changes at a point (x_0,y_0,z_0) in the direction u.
     It is a vector form of the usual derivative, and can be defined as
     del _(u)f = del f·(u)/(|u|)

     - Parameters:
        - fun: A multivariate function of 2, 3, or more independent variables.
        - direction: The direction in which we are interested in finding the function's rate of change. (u)
        - independentVars: A list denoting the independent variables of the function.
     - Returns: A vector function of n variables that computes the rate at
                which the function is changing in the direction of u.
     */
    public static func directionalDifferentiation(
        of fun: Function,
        direction: Vector,
        independentVars vars: [Variable]) throws -> Vector {
        
        let unitVec = direction.unitVector
        let grad = gradient(of: fun, independentVars: vars)
        return try grad.perform(*, with: unitVec)
    }
    
    /**
     The gradient of a function is the multivariable version of the derivative.
     Suppose we have a function, f(x1,x2,...xn), the gradient of function f
     is a vector of n dimension with the definition v = [∂f/∂x1, ∂f/∂x2, ..., ∂f/∂xn].
     
     Find more about the definition of a gradient:
     https://math.oregonstate.edu/home/programs/undergrad/CalculusQuestStudyGuides/vcalc/grad/grad.html
     
     - Parameters:
        - fun: A multivariate function of 2, 3, or more independent variables.
        - independentVars: A list denoting the independent variables of the function.
     - Returns: The gradient vector of the function.
     */
    public static func gradient(of fun: Function, independentVars vars: [Variable]) -> Vector {
        return Vector(vars.map {derivative(of: fun, withRespectTo: $0) ?? Function(.derivative, [fun, $0])})
    }
    
    /**
     Implicit differentiation using concepts of partial derivatives in multivariable calculus.
     
     let x = independent var;
     let y = f(x) -> dependent var;
     suppose we have x ^ 2 + 2x + 3yx = y^2;
     define a function, F(x, y) = x ^ 2 + 2x + 3yx - y^2 = 0;
     Fx = ∂F/∂x, Fy = ∂F/∂y;
     thus we arrive at dy/dx = -Fx / Fy.
     
     - Parameters:
     - eq: An equation that defines the relationship b/w the dependent var and the independent var.
     - dependentVar: The dependent variable (x)
     - independentVar: The independent variable (y)
     - Returns: dy/dx - the result of the implicit differentiation
     */
    public static func implicitDifferentiation(
        _ eq: Equation,
        dependentVar dv: Variable,
        independentVar iv: Variable) throws -> Node? {
        
        let f = try (eq.lhs - eq.rhs).simplify()
        let fx = derivative(of: f, withRespectTo: dv) ?? Function(.derivative, [f, dv])
        let fy = derivative(of: f, withRespectTo: iv) ?? Function(.derivative, [f, iv])
        
        return -fx / fy
    }
    
    /**
     Take the nth derivative of node n.
     - Parameters:
        - v: The variable with respect to which the derivative is taken.
        - nth: Nth derivative.
     - Returns: The nth derivative of n, if taken successfully.
     */
    public static func derivative(of n: Node, withRespectTo v: Variable, _ nth: Int) throws -> Node? {
        var n = n
        for i in 0..<nth {
            if let d = derivative(of: n, withRespectTo: v) {
                n = try d.simplify()
            } else {
                return i == 0 ? nil : Function(.derivative, [n, v, nth - i])
            }
        }
        return n
    }
    
    /**
     Take the (partial) derivative of node n w/ respect to variable v.
     
     - Parameters:
        - n: The node to be differentiated
        - v: The variable for which the derivative is taken with respect to.
     - Returns: The derivative of n w/ respect to v.
     */
    public static func derivative(of n: Node, withRespectTo v: Variable) -> Node? {
        if let v1 = n as? Variable {
            
            // Irrelevant variables are treated as constants.
            return v1.name == v.name ? 1 : 0
        } else if n is NSNumber {
            return 0
        } else if let fun = n as? Function {
            var bigKahuna: Node?
            if fun.count == 1 {
                let o = fun[0]
                switch fun.name {
                case "log":
                    bigKahuna = 1 / o * log("e"&)
                case "ln":
                    bigKahuna = 1 / fun[0]
                case "cos":
                    bigKahuna = -sin(o)
                case "sin":
                    bigKahuna = cos(o)
                case "tan":
                    bigKahuna = 1 / (cos(o) ^ 2)
                case "acos":
                    bigKahuna = -1 / √(1 - o ^ 2)
                case "asin":
                    bigKahuna = -acos(o)
                case "atan":
                    bigKahuna = 1 / (o ^ 2 + 1)
                case "abs":
                    bigKahuna = sign(o)
                case "csc":
                    bigKahuna = -cos(o) / (sin(o) ^ 2)
                case "sec":
                    bigKahuna = sin(o) / (cos(o) ^ 2)
                case "cot":
                    bigKahuna = -1 / (sin(o) ^ 2)
                case "cosh":
                    bigKahuna = sinh(o)
                case "sinh":
                    bigKahuna = cosh(o)
                case "tanh":
                    bigKahuna = 1 / (cosh(o) ^ 2)
                default:
                    break
                }
                if let big = bigKahuna {
                    return derivative(of: fun.elements, withRespectTo: v)[0] * big
                }
            } else {
                switch fun.name {
                case "+":
                    
                    // d/dx [f(x) + g(x) + ...] = d/dx(g(x)) + d/dx(g(x)) + ...
                    let smallKahunas = derivative(of: fun.elements, withRespectTo: v)
                    return ++smallKahunas
                case "*":
                    
                    // d/dx [f(x) * g(x) * ...] = d/dx(f(x)) * g(x) + d/dx(g(x)) * f(x) + ...
                    var nodes = [Node]()
                    for (i, kahuna) in fun.elements.enumerated() {
                        var j = fun.elements
                        j.remove(at: i)
                        j.append(Function(.derivative, [kahuna, v]))
                        nodes.append(**j)
                    }
                    
                    return ++nodes
                case "^":
                    
                    // Logarithmic differentiation
                    // y = f(x)^g(x)
                    // ln(y) = g(x)*ln(f(x)) -- Apply implicit differentiation
                    // dy/dx * 1/y = d/dx[g(x)*ln(f(x))]
                    // dy/dx = d/dx[g(x)*ln(f(x))] * y
                    assert(fun.count == 2)
                    let base = fun[0]
                    let exp = fun[1]
                    let k = Function(.derivative, [ln(base) * exp, v])
                    return k * fun
                default:
                    break
                }
            }
        }
        
        return nil
    }

    
    public static func derivative(of nodes: [Node], withRespectTo v: Variable) -> [Node] {
        return nodes.map {
            Function(.derivative, [$0, v])
        }
    }
}
