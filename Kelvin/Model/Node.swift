//
//  Node.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

// Unary operation
public typealias Unary = (Node) -> Node

/// Unary predicament
public typealias PUnary = (Node) -> Bool

/// Binary predicament
public typealias PBinary = (Node, Node) -> Bool

public protocol Node: CustomStringConvertible {
    
    /// The string representation of the node.
    /// This is used to override the description implemented in Double;
    /// It serves as an intermediate.
    var stringified: String {get}
    
    /// Computes the numerical value that the node represents.
    var evaluated: Value? {get}
    
    /// The complexity of the node.
    /// Variables have a complexity of 2, constants have a complexity of 1;
    /// the complexity of List is the sum of the complexity of all of
    /// its elements + 1. The complexity of functions are computed as
    /// the complexity of the List of arguments + 1. 
    var complexity: Int {get}
    
    /// Simplify the node.
    /// TODO: Implement Log
    func simplify() -> Node
    
    /// Perform an action on each node in the tree.
    func forEach(_ body: (Node) -> ())
    
    /**
     - Parameters:
        - predicament: The condition for the matching node.
        - depth: Search depth. Won't search for nodes beyond this designated depth.
     - Returns: Whether the current node contains the target node.
     */
    func contains(where predicament: PUnary, depth: Int) -> Bool
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
                            ignores it) and returns a node as replacement.
     */
    func replacing(by replace: Unary, where predicament: PUnary) -> Node
    
    /// - Returns: Whether the provided node is identical with self.
    func equals(_ node: Node) -> Bool
}

/// Interface with CustomStringConvertible.
extension Node {
    public var description: String {
        return stringified
    }
}

/// Infix shorthand for lhs.equals(rhs)
public func ===(_ lhs: Node, _ rhs: Node) -> Bool {
    return lhs.equals(rhs)
}

/// Infix shorthand for !lhs.equals(rhs)
public func !==(_ lhs: Node, _ rhs: Node) -> Bool {
    return !(lhs === rhs)
}

public func +(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("+", [lhs, rhs])
}

public func -(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("-", [lhs, rhs])
}

public func ^(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("^", [lhs, rhs])
}

public func *(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("*", [lhs, rhs])
}

prefix operator *
public prefix func *(_ args: [Node]) -> Node {
    assert(args.count > 2)
    return Function("*", args)
}

prefix operator **
public prefix func **(_ args: [Node]) -> Node {
    if args.count == 0 {
        return 1
    } else if args.count == 1 {
        return args[0]
    }
    return Function("*", args)
}

public func /(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("/", [lhs, rhs])
}

public prefix func -(_ arg: Node) -> Node {
    return Function("negate", [arg])
}
