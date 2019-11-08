//
//  Algebra+expand.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

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
    
    /// Performs `n` degree multinomial expansion on `terms` uisng multinomial theorem.
    /// Refer to https://en.wikipedia.org/wiki/Multinomial_theorem
    /// e.g. `(a + b)^2 = a^2 + 2ab + b^2`
    /// - Parameters:
    ///     - terms Terms to perform the expansion with.
    ///     - degrees Degree of power
    /// - Precondition: `terms` has to be an addition.
    static func multinomialExpansion(_ terms: Function, degrees n: Int) throws -> Node {
        try Assert.equals(terms.name, OperationName.add, message: "can only perform multinomial expansion on addition terms")
        try Assert.domain(n, 1, Int.max)
        let terms = terms.elements
        let num = n.factorial()
        return try ++sum(to: n, using: terms.count).map {
            degrees -> Node in
            let denom = degrees.map { $0.factorial() }
                .reduce(BigInt(1)) { $0 * $1 }
            let coef = num / denom
            var term: [Node] = degrees.enumerated()
                .filter { $0.element != 0 }
                .map {
                    let t = terms[$0.offset]
                    if ($0.element == 1) {
                        return t
                    }
                    return Function(.power, [t, $0.element])
            }
            if coef != 1 {
                term.insert(coef, at: 0)
            }
            // x 6 time complexity
            return try (**term).simplify()
        }
    }
    
    /// - Returns: All possible permutations of m integers greater than or equal to 0 whose sum is n.
    private static func sum(to n: Int, using m: Int) -> [[Int]] {
        if (n == 0) {
            return [[Int](repeating: 0, count: m)]
        }
        if (m == 1) {
            return [[n]]
        } else if (m == 0) {
            return []
        }
        var results = [[Int]]()
        for i in 0...n {
            results.append(
                contentsOf: sum(to: n - i, using: m - 1).map {
                    (r: [Int]) -> [Int] in
                    var r = r
                    r.insert(i, at: 0)
                    return r
                }
            )
        }
        return results
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
            } else if let c = rhs as? Int, let base = lhs as? Function {
                switch base.name {
                case .mult:
                    // a ^ 3 = a * a * a
                    // a ^ -3 = 1 / (a * a * a)
                    let expanded = recursivelyExpand(**[Node](repeating: lhs, count: abs(c)))
                    return c > 0 ? expanded : 1 / expanded
                case .add:
                    // (a + b + c + ...) ^ n, apply multinomial expansion
                    return try! multinomialExpansion(base, degrees: c)
                default:
                    break
                }
            }
        default:
            break
        }
        
        return node
    }
}
