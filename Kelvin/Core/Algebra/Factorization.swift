//
//  Factorization.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Factorization (one of the most complex algorithms I wrote...)
public extension Algebra {
    
    private static var time: TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    /// Factorizes the parent node; e.g. a*b+a*c becomes a*(b+c)
    static func factorize(_ parent: Node) throws -> Node {
        return try parent.replacing(by: {
            try factorize(time, limitedBy: 1.0, ($0 as! Function).elements)
        }) {
            ($0 as? Function)?.name == .add
        }
    }
    
    /**
     Try these!!
     factor(x * a + x + a + 1)
     factor(x * c + x * b + c * a + b * a)
     factor(x * a + x * 2 + a + 2)
     factor(z * b + z * a + y * b + y * a + x * b + x * a)
     factor(z * d * a + z * b + y * d * a + y * b + x * d * a + x * b)
     factor(z * d * a + z * b * 2 + y * d * a + y * b * 2 + x * d * a + x * b * 2)
     factor(e * b * a + d * b * a - d * c * a * 2 - e * c * a * 2)
     factor(x * f * c + x * f * b + x * d * c + x * d * b + f * c * a + f * b * a + d * c * a + d * b * a)
     
     - Todo: Use long division for factorization!
     - Todo: Return once further factorization is no longer possible (this will be hard...)
     - Parameter nodes: The arguments of a summation function
     - Returns: The factorized form of arguments.
     */
    private static func factorize(
        _ startTime: TimeInterval,
        limitedBy duration: TimeInterval,
        _ nodes: [Node]) throws -> Node {
        
        var nodes = nodes
        if nodes.count == 0 {
            fatalError("an unexpected error has occurred during factorization")
        } else if nodes.count == 1 {
            return nodes.first!
        }
        
        var factorizedForms = [Node]()
        
        func combinedForms(of n: [Node], num: Int) -> [[Node]] {
            var cb = [[Node]]()
            let cs = combinations(of: (0..<n.count).map {$0}, num)
            for c in cs {
                var j = [Node]()
                var k = [Node]()
                var n = n
                c.reversed().forEach {j.append(n.remove(at: $0))}
                k.append(contentsOf: n)
                k.append(++j)
                cb.append(k)
            }
            return cb
        }
        
        for i in 0..<nodes.count {
            
            // If the expression can't be factorized in reasonable time, return the current
            // simplest form.
            if time - startTime > duration {
                break
            }
            
            let n1 = nodes.remove(at: i)
            for j in i..<nodes.count {
                let n2 = nodes.remove(at: j)
                let factors = commonFactors([n1, n2])
                
                // For each common factor, factorize n1 and n2 by the common factor,
                // simplify (if possible), then add the factored form back into the pool
                // for further factorization.
                for f in factors {
                    let a = factorize(n1, by: f)
                    let b = factorize(n2, by: f)
                    let fab = try factorize(a + b)
                        .simplify()
                    
                    var pool = nodes
                    pool.append(f * fab)
                    
                    // Recursively factor the updated nodes pool, then choose
                    // the simpliest permutation of the recursively factorized forms
                    // and add it to the list of factorized forms at this level.
                    let factorized = try factorize(startTime, limitedBy: duration, pool)
                    
                    // Immediately return if the expression is factorized!
                    if (factorized as? Function)?.name == .mult {
                        return factorized
                    }
                    factorizedForms.append(factorized)
                }
                nodes.insert(n2, at: j)
            }
            
            if nodes.count < 2 {
                nodes.insert(n1, at: i)
                continue
            }
            
            for q in 2...nodes.count {
                for var c in combinedForms(of: nodes, num: q) {
                    let combined = c.removeLast()
                    
                    for f in commonFactors([n1, combined]) {
                        let a = factorize(n1, by: f)
                        let b = factorize(combined, by: f)
                        let fab = try factorize(a + b).simplify()
                        c.append(f * fab)
                        
                        let factorized = try factorize(startTime, limitedBy: duration, c)
                        
                        // Immediately return if the expression is factorized!
                        if (factorized as? Function)?.name == .mult {
                            return factorized
                        }
                        
                        factorizedForms.append(factorized)
                    }
                }
            }
            
            nodes.insert(n1, at: i)
        }
        
        // Return the simplest permutation of all factorized forms.
        return try factorizedForms.map {
            try $0.simplify()
            }.sorted {
                $0.complexity < $1.complexity
            }.first ?? ++nodes
    }
    
    /**
     Factorizes a node by a given factor.
     
     - Note: This function assumes that the relationship b/w node and factor is addition.
     - Parameters:
     - node: The node to be factorized with factor
     - factor: The factor used to factorize the node.
     - Returns: Given node with factor factorized out.
     */
    private static func factorize(_ node: Node, by factor: Node) -> Node {
        return try! (node / factor).simplify()
    }
    
    // Deconstruct a node into its arguments if it is "*"
    // For nodes other than "*", return the node itself.
    private static func deconstruct(_ node: Node) -> [Node] {
        if let fun = node as? Function {
            switch fun.name {
            case .mult:
                return fun.elements.map {n -> [Node] in
                    if let i = n as? Int {
                        return primeFactors(of: i)
                    }
                    return [n]
                    }.flatMap {
                        $0
                }
            case .exp:
                let base = fun[0]
                let exponent = fun[1]
                // TODO: Handle fractions
                if let i = exponent as? Int {
                    var nodes = [Node]()
                    
                    if i > 1 {
                        nodes.append(base)
                        for q in 2...i {
                            nodes.append(base ^ q)
                        }
                        return nodes
                    }
                    
                    // TOTO: Handle negative exponents
                }
            default:
                break
            }
        } else if let i = node as? Int {
            return primeFactors(of: i)
        }
        return [node]
    }
    
    /**
     Find the common terms of nodes in terms of multiplication.
     It is assumed that the relationship b/w nodes is addition.
     
     - Note: 1 is not returned as a common factor.
     - Parameter nodes: The nodes from which common terms are derived.
     - Returns: Common factors of nodes excluding 1.
     */
    private static func commonFactors(_ nodes: [Node]) -> [Node] {
        var nodes = nodes
        
        // Base case
        if nodes.count == 0 {
            return []
        } else if nodes.count == 1 {
            return nodes
        }
        
        // Common terms
        var common = [Node]()
        
        // Remove the first node from the list
        let node = nodes.removeFirst()
        
        // If any of the nodes are 1, then the expression is not factorizable.
        // e.g. a*b*c + 1 + b*c*d is not factorizable and will eventually cause stack overflow.
        if node === 1 {
            return []
        }
        
        // Deconstruct the node into its operands(arguments)
        let operands = deconstruct(node)
        
        // For each operand of the "*" node, check if it is present in
        // all of the other nodes.
        for o in operands {
            var isCommon = true
            for n in nodes {
                let isFactor = deconstruct(n).contains {$0 === o}
                
                // If one of the remaining nodes is not 'o' and does not contain 'o',
                // we know that 'o' is not a common factor. Immediately exit the loop.
                if !(isFactor || n === o) {
                    isCommon = false
                    break
                }
            }
            
            // If 'o' is a common factor, then we add 'o' to the common factor array,
            // then factorize each term by 'o', and recursively factor what remains
            // to find the rest of the factors.
            if isCommon {
                common.append(o)
                nodes.insert(node, at: 0)
                
                // Factorize each node with 'o'
                let remaining = nodes.map {
                    factorize($0, by: o)
                }
                
                // Find common terms of the remaining nodes, recursively.
                let c = commonFactors(remaining)
                common.append(contentsOf: c)
                return common
            }
        }
        
        // If none of the operands in the first node is factorizable,
        // then the expression itself is not factorizable.
        return []
    }
}
