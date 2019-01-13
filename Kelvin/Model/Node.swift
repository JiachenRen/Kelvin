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

public protocol Node: CustomStringConvertible {
    
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
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
                            ignores it) and returns a node as replacement.
     */
    func replacing(by replace: Unary, where predicament: (Node) -> Bool) -> Node
    
    /// - Returns: Whether the provided node is identical with self.
    func equals(_ node: Node) -> Bool
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

public func /(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("/", [lhs, rhs])
}

public prefix func -(_ arg: Node) -> Node {
    return Function("negate", [arg])
}
