//
//  Calculus.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let calculusOperations: [Operation] = [
    .init("derivative", [.any, .var]) {
        CalculusEngine.derivative(of: $0[0], withRespectTo: $0[1] as! Variable)
    },
    .init("derivative", [.any, .var, .number]) {
        try CalculusEngine.derivative(of: $0[0], withRespectTo: $0[1] as! Variable, $0[2] as! Int)
    },
]

fileprivate class CalculusEngine {
    
    /**
     Take the nth derivative of node n.
     - Parameters:
        - v: The variable with respect to which the derivative is taken.
        - nth: Nth derivative.
     - Returns: The nth derivative of n, if taken successfully.
     */
    fileprivate static func derivative(of n: Node, withRespectTo v: Variable, _ nth: Int) throws -> Node? {
        var n = n
        for i in 0..<nth {
            if let d = derivative(of: n, withRespectTo: v) {
                n = try d.simplify()
            } else {
                return i == 0 ? nil : Function("derivative", [n, v, nth - i])
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
    fileprivate static func derivative(of n: Node, withRespectTo v: Variable) -> Node? {
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
                    bigKahuna = 1 / o * log(try! Variable("e"))
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
                        j.append(Function("derivative", [kahuna, v]))
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
                    let k = Function("derivative", [ln(base) * exp, v])
                    return k * fun
                default:
                    break
                }
            }
        }
        
        return nil
    }

    
    fileprivate static func derivative(of nodes: [Node], withRespectTo v: Variable) -> [Node] {
        return nodes.map {
            Function("derivative", [$0, v])
        }
    }
}
