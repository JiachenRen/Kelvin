//
//  Calculus+differentiation.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Calculus {
    
    /// Generic operation for calculating the tangential line/plane/surface of a function
    /// of n variables in multivariable.
    /// Suppose you want to find the tangent of equation `y = x^2`, first convert it to a function:
    /// `y - x^2 = 0 -> f(x,y) = y - x^2`, where `f(x, y) = 0`.
    /// Then, invoking `tangent(_:_:_:)` with `f(x, y)`, `{x, y}`, and a point `[a, b]` would give the
    /// expected equation for the tangent line, `1(y - b) + 2a(x - a) = 0`.
    ///
    /// - Parameters:
    ///     - point: A vector representing a point on the function.
    ///     - fun: A function of n variables.
    ///     - variables: The independent variables of `fun`
    static func tangent(
        of fun: Function,
        variables: [Variable],
        at point: Vector) throws -> Equation {
        guard variables.count == point.count else {
            let msg = "The function with arguments \(Vector(variables).stringified) cannot be evaluated with the given point \(point.stringified)"
            throw ExecutionError.general(errMsg: msg)
        }
        
        let grad = gradient(of: fun, independentVars: variables)
        let defs = zip(variables, point.elements).map {
            Equation(lhs: $0, rhs: $1)
        }
        let components = try grad.elements.map {
            try Function(.evaluateAt, [$0, Vector(defs)])
                .simplify()
        }
        
        let deltas = zip(variables, point.elements)
            .map {$0 - $1}
        let lhs = ++zip(components, deltas)
            .map {$0 * $1}
        return Equation(lhs: lhs, rhs: 0)
    }
    
    /// The directional derivative `del _(u)f(x_0,y_0,z_0)` is the rate at which the function `f(x,y,z)`
    /// changes at a point `(x_0,y_0,z_0)` in the direction `u`.
    /// It is a vector form of the usual derivative, and can be defined as
    /// `del _(u)f = del f·(u)/(|u|)`
    ///
    /// - Parameters:
    ///    - fun: A multivariate function of 2, 3, or more independent variables.
    ///    - direction: The direction in which we are interested in finding the function's rate of change. (u)
    ///    - independentVars: A list denoting the independent variables of the function.
    /// - Returns: A function containing variables identical to the independent variables provided
    /// that computes the slope of the function in the specified direction
    ///
    static func directionalDifferentiation(
        of fun: Function,
        direction: Vector,
        independentVars vars: [Variable]) throws -> Node {
        
        let unitVec = direction.unitVector
        let grad = gradient(of: fun, independentVars: vars)
        return try grad.dot(with: unitVec)
    }
    
    /// The gradient of a function is the multivariable version of the derivative.
    /// Suppose we have a function, `f(x1,x2,...xn)`, the gradient of function f
    /// is a vector of n dimension with the definition `v = [∂f/∂x1, ∂f/∂x2, ..., ∂f/∂xn]`.
    ///
    /// Find more about the definition of a gradient:
    /// https://math.oregonstate.edu/home/programs/undergrad/CalculusQuestStudyGuides/vcalc/grad/grad.html
    ///
    /// - Parameters:
    ///     - fun: A multivariate function of 2, 3, or more independent variables.
    ///     - independentVars: A list denoting the independent variables of the function.
    ///     - Returns: The gradient vector of the function.
    ///
    static func gradient(of fun: Function, independentVars vars: [Variable]) -> Vector {
        return Vector(vars.map {derivative(of: fun, withRespectTo: $0) ?? Function(.derivative, [fun, $0])})
    }
    
    /// Implicit differentiation using concepts of partial derivatives in multivariable calculus.
    ///
    /// First declare the following:
    /// `let x = independent var`
    /// `let y = f(x) -> dependent var`
    ///
    /// Suppose we have `x ^ 2 + 2x + 3yx = y^2`
    /// Define a function, `F(x, y) = x ^ 2 + 2x + 3yx - y^2 = 0`
    /// `Fx = ∂F/∂x, Fy = ∂F/∂y`
    /// thus we arrive at `dy/dx = -Fx / Fy`.
    ///
    /// - Parameters:
    ///     - eq: An equation that defines the relationship b/w the dependent var and the independent var.
    ///     - dependentVar: The dependent variable `x`
    ///     - independentVar: The independent variable `y`
    /// - Returns: `dy/dx` - the result of the implicit differentiation
    ///
    static func implicitDifferentiation(
        _ eq: Equation,
        dependentVar dv: Variable,
        independentVar iv: Variable) throws -> Node? {
        
        let f = try (eq.lhs - eq.rhs).simplify()
        let fx = derivative(of: f, withRespectTo: dv) ?? Function(.derivative, [f, dv])
        let fy = derivative(of: f, withRespectTo: iv) ?? Function(.derivative, [f, iv])
        
        return -fx / fy
    }
    
    /// Takes the nth derivative of node `n`.
    ///
    /// - Parameters:
    ///     - v: The variable with respect to which the derivative is taken.
    ///     - nth: Nth derivative.
    ///     - Returns: The nth derivative of n, if taken successfully.
    /// - Returns: The nth derivative of node `n`.
    static func derivative(of n: Node, withRespectTo v: Variable, _ nth: Int) throws -> Node? {
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
    
    /// Takes the (partial) derivative of node `n`w/ respect to variable `v`.
    ///
    /// - Parameters:
    ///    - n: The node to be differentiated
    ///    - v: The variable for which the derivative is taken with respect to.
    /// - Returns: The derivative of `n` w/ respect to `v`.
    static func derivative(of n: Node, withRespectTo v: Variable) -> Node? {
        if let v1 = n as? Variable {
            // Irrelevant variables are treated as constants.
            return v1.name == v.name ? 1 : 0
        } else if n is Number {
            return 0
        } else if let fun = n as? Function {
            var bigKahuna: Node?
            if fun.count == 1 {
                let o = fun[0]
                switch fun.name {
                case .log:
                    bigKahuna = 1 / o * log("e"&)
                case .ln:
                    bigKahuna = 1 / fun[0]
                case .cos:
                    bigKahuna = -sin(o)
                case .sin:
                    bigKahuna = cos(o)
                case .tan:
                    bigKahuna = 1 / (cos(o) ^ 2)
                case .acos:
                    bigKahuna = -1 / √(1 - o ^ 2)
                case .asin:
                    bigKahuna = -acos(o)
                case .atan:
                    bigKahuna = 1 / (o ^ 2 + 1)
                case .abs:
                    bigKahuna = sign(o)
                case .csc:
                    bigKahuna = -cos(o) / (sin(o) ^ 2)
                case .sec:
                    bigKahuna = sin(o) / (cos(o) ^ 2)
                case .cot:
                    bigKahuna = -1 / (sin(o) ^ 2)
                case .cosh:
                    bigKahuna = sinh(o)
                case .sinh:
                    bigKahuna = cosh(o)
                case .tanh:
                    bigKahuna = 1 / (cosh(o) ^ 2)
                default:
                    break
                }
                if let big = bigKahuna {
                    if let small = derivative(of: fun[0], withRespectTo: v) {
                        return small * big
                    }
                    return Function(.derivative, [fun[0]]) * big
                }
            } else {
                switch fun.name {
                case .add:
                    
                    // d/dx [f(x) + g(x) + ...] = d/dx(g(x)) + d/dx(g(x)) + ...
                    let smallKahunas = derivative(of: fun.elements, withRespectTo: v)
                    return ++smallKahunas
                case .mult:
                    
                    // d/dx [f(x) * g(x) * ...] = d/dx(f(x)) * g(x) + d/dx(g(x)) * f(x) + ...
                    var nodes = [Node]()
                    for (i, kahuna) in fun.elements.enumerated() {
                        var j = fun.elements
                        j.remove(at: i)
                        j.append(Function(.derivative, [kahuna, v]))
                        nodes.append(**j)
                    }
                    
                    return ++nodes
                case .power:
                    
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
    
    static func derivative(of nodes: [Node], withRespectTo v: Variable) -> [Node] {
        return nodes.map {
            Function(.derivative, [$0, v])
        }
    }
}
