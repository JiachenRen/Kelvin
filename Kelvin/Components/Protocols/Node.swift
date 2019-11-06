//
//  Node.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol Node {
    
    /// The string representation of the node.
    /// This is used to override the description implemented in Float80;
    /// It serves as an intermediate.
    var stringified: String { get }
    
    var ansiColored: String { get }

    /// Computes the numerical value that the node represents.
    var evaluated: Number? { get }
    
    /// Used to determine if a parenthesis is needed
    var precedence: Keyword.Precedence { get }

    /// The complexity of the node.
    /// Variables have a complexity of 2, constants have a complexity of 1;
    /// the complexity of Vector is the sum of the complexity of all of
    /// its elements + 1. The complexity of functions are computed as
    /// the complexity of the Vector of arguments + 1. 
    var complexity: Int { get }

    /// Simplify the node.
    func simplify() throws -> Node

    /// Perform an action on each node in the tree.
    func forEach(_ body: (Node) -> ())

    /// - Parameters:
    ///    - predicament: The condition for the matching node.
    ///    - depth: Search depth. Won't search for nodes beyond this designated depth.
    /// - Returns: Whether the current node contains the target node.
    func contains(where predicament: PUnary, depth: Int) -> Bool

    /// Replace the designated nodes identical to the node provided with the replacement
    ///
    /// - Parameter predicament: The condition that needs to be met for a node to be replaced
    /// - Parameter replace:   A function that takes the old node as input (and perhaps
    ///                        ignores it) and returns a node as replacement.
    func replacing(by replace: (Node) throws -> Node, where predicament: PUnary) rethrows -> Node

    /// - Returns: Whether the provided node is identical with self.
    func equals(_ node: Node) -> Bool
    
    /// Make a copy of self
    func copy() -> Self
}

extension Node {
    
    /// Replace anonymous closure arguments `$0`, `$1`, etc. w/ supplied arguments.
    /// - Parameter args: Replacements for anonymous closure args
    /// - Returns: Node w/ closure args replaced w/ supplied args.
    public func replacingAnonymousArgs(with args: [Node]) -> Node {
        return self.replacing(by: {n in
            let v = n as! Variable
            var name = v.name
            name.removeFirst()
            
            // If the variable is an anonymous closure argument,
            // replace it with the supplied argument.
            if let i = Int(name) {
                if i < args.count && i >= 0 {
                    return args[i]
                }
            }
            
            return v
        }) {
            ($0 as? Variable)?.name.starts(with: "$") ?? false
        }
    }
    
    /// Finalizes the node such that it is left as-is during simplification.
    public func finalize() -> Node {
        return Final(self)
    }
}
