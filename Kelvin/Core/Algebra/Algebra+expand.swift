//
//  Algebra+expand.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Algebra {
    
    /// Expands the given expression.
    /// Try these:
    /// `expand((x+1)(a+x)(b+x))`
    /// `expand((a+b)^3)`
    /// `expand((a+b)^(3+a))`
    static func expand(_ node: Node) -> Node {
        return node.replacing(by: {(n) -> Node in
                recursivelyExpand(n)
            }) {_ in true }
    }
    
    /// Recursively expands the node.
    /// - Parameter node: The node to be expanded.
    private static func recursivelyExpand(_ node: Node) -> Node {
        // First ensure that we are working with a function
        guard let fun = node as? Function else {
            return node
        }
        
        // Extract the function's arguments
        var args = fun.elements
        
        switch fun.name {
        case .mult:
            for i in 0..<args.count {
                let n = args.remove(at: i)
                if let f = n as? Function, f.name == .add {
                    return ++(f.elements.map {
                        recursivelyExpand($0 * **args)
                    })
                }
                args.insert(n, at: i)
            }
        case .power:
            let lhs = fun[0], rhs = fun[1]
            if let rhsFun = rhs as? Function {
                switch rhsFun.name {
                case .add:
                    // a ^ (b + c) = a ^ b * a ^ c
                    let expanded = **rhsFun.elements.map {
                        recursivelyExpand(lhs ^ $0)
                    }
                    return recursivelyExpand(expanded)
                default:
                    break
                }
            } else if let c = rhs as? Int {
                // a ^ 3 = a * a * a
                // a ^ -3 = 1 / (a * a * a)
                let expanded = recursivelyExpand(**[Node](repeating: lhs, count: abs(c)))
                return c > 0 ? expanded : 1 / expanded
            }
        default:
            break
        }
        
        return node
    }
}
