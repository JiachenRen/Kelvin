//
//  Algebra.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Algebraic operations (factorization, expansion)
let algebraicOperations: [Operation] = [
    .unary("factor", [.any]) {
        AlgebraEngine.factorize($0)
    },
]

fileprivate class AlgebraEngine {

    /// Factorizes the parent node; e.g. a*b+a*c becomes a*(b+c)
    fileprivate static func factorize(_ parent: Node) -> Node {
        return parent.replacing(by: {
            factorize(($0 as! Function).elements)
        }) {
            ($0 as? Function)?.name == "+"
        }
    }

    /**
     - Todo: Return the simplest form of factorization.
     - Parameter nodes: The arguments of a summation function
     - Returns: The factorized form of arguments.
     */
    fileprivate static func factorize(_ nodes: [Node]) -> Node {
        var nodes = nodes
        let factors = commonFactors(nodes)
        for f in factors {
            nodes = nodes.map {
                factorize($0, by: f)
            }
        }
        return **factors * ++nodes
    }

    /**
     Factorizes a node by a given factor.
     
     - Note: This function assumes that the relationship b/w node and factor is addition.
     - Parameters:
     - node: The node to be factorized with factor
     - factor: The factor used to factorize the node.
     - Returns: Given node with factor factorized out.
     */
    fileprivate static func factorize(_ node: Node, by factor: Node) -> Node {
        if node === factor {
            return 1
        }
        let mult = node as! Function
        assert(mult.name == "*")

        var elements = mult.elements
        for (i, e) in elements.enumerated() {
            if e === factor {
                elements.remove(at: i)
                break
            }
        }

        return **elements
    }

    /**
     Find the common terms of nodes in terms of multiplication.
     It is assumed that the relationship b/w nodes is addition.
     
     - Note: 1 is not returned as a common factor.
     - Parameter nodes: The nodes from which common terms are derived.
     - Returns: Common factors of nodes excluding 1.
     */
    fileprivate static func commonFactors(_ nodes: [Node]) -> [Node] {
        var nodes = nodes

        // Base case
        if nodes.count == 0 {
            return []
        } else if nodes.count == 1 {
            return nodes
        }

        // Deconstruct a node into its arguments if it is "*"
        // For nodes other than "*", return the node itself.
        func deconstruct(_ node: Node) -> [Node] {
            if let mult = node as? Function, mult.name == "*" {
                return mult.elements
            }
            return [node]
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
                let isFactor = (n as? Function)?.name == "*" && n.contains(where: { $0 === o }, depth: 1)

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
