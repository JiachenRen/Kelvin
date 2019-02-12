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

// Binary operation
public typealias Binary = (Node, Node) -> Node

/// Unary predicament
public typealias PUnary = (Node) -> Bool

/// Binary predicament
public typealias PBinary = (Node, Node) -> Bool

public protocol Node {

    /// The string representation of the node.
    /// This is used to override the description implemented in Double;
    /// It serves as an intermediate.
    var stringified: String { get }
    
    var ansiColored: String { get }

    /// Computes the numerical value that the node represents.
    var evaluated: Value? { get }
    
    /// Used to determine if a parenthesis is needed
    var precedence: Keyword.Precedence { get }

    /// The complexity of the node.
    /// Variables have a complexity of 2, constants have a complexity of 1;
    /// the complexity of List is the sum of the complexity of all of
    /// its elements + 1. The complexity of functions are computed as
    /// the complexity of the List of arguments + 1. 
    var complexity: Int { get }

    /// Simplify the node.
    /// TODO: Implement Log
    func simplify() throws -> Node

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
    func replacing(by replace: (Node) throws -> Node, where predicament: PUnary) rethrows -> Node

    /// - Returns: Whether the provided node is identical with self.
    func equals(_ node: Node) -> Bool
}

extension Node {
    
    /**
     Replace anonymous closure arguments $0, $1, etc. w/ supplied arguments.
     
     - Parameter args: Replacements for anonymous closure args
     - Returns: Node w/ closure args replaced w/ supplied args.
     */
    func replacingAnonymousArgs(with args: [Node]) -> Node {
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

prefix operator +

public prefix func +(_ args: [Node]) -> Node {
    assert(args.count >= 2)
    return Function("+", args)
}

prefix operator ++

public prefix func ++(_ args: [Node]) -> Node {
    if args.count == 0 {
        return 0
    } else if args.count == 1 {
        return args[0]
    }
    return Function("+", args)
}

postfix operator ++

public postfix func ++(_ arg: Node) -> Node {
    return Function("++", [arg])
}

postfix operator --

public postfix func --(_ arg: Node) -> Node {
    return Function("--", [arg])
}

infix operator +==

public func +==(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("+=", [lhs, rhs])
}

infix operator -==

public func -==(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("-=", [lhs, rhs])
}

infix operator *==

public func *==(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("*=", [lhs, rhs])
}

infix operator /==

public func /==(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("/=", [lhs, rhs])
}

infix operator &&&

public func &&&(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("and", [lhs, rhs])
}

infix operator |||

public func |||(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("or", [lhs, rhs])
}

prefix operator !!

public prefix func !!(_ arg: Node) -> Node {
    return Function("not", [arg])
}

postfix operator ~!

public postfix func ~!(_ arg: Node) -> Node{
    return Function("factorial", [arg])
}

prefix operator √

public prefix func √(_ arg: Node) -> Node {
    return Function("sqrt", [arg])
}

public func /(_ lhs: Node, _ rhs: Node) -> Node {
    return Function("/", [lhs, rhs])
}

public prefix func -(_ arg: Node) -> Node {
    return Function("negate", [arg])
}

public func sin(_ arg: Node) -> Node {
    return Function("sin", [arg])
}

public func cos(_ arg: Node) -> Node {
    return Function("cos", [arg])
}

public func tan(_ arg: Node) -> Node {
    return Function("tan", [arg])
}

public func atan(_ arg: Node) -> Node {
    return Function("atan", [arg])
}

public func acos(_ arg: Node) -> Node {
    return Function("acos", [arg])
}

public func asin(_ arg: Node) -> Node {
    return Function("asin", [arg])
}

public func tanh(_ arg: Node) -> Node {
    return Function("tanh", [arg])
}

public func cosh(_ arg: Node) -> Node {
    return Function("cosh", [arg])
}

public func sinh(_ arg: Node) -> Node {
    return Function("sinh", [arg])
}

public func log(_ arg: Node) -> Node {
    return Function("log", [arg])
}

public func ln(_ arg: Node) -> Node {
    return Function("ln", [arg])
}

public func sign(_ arg: Node) -> Node {
    return Function("sign", [arg])
}

postfix operator ≈

public postfix func ≈(_ node: Node) -> Double? {
    return node.evaluated?.doubleValue
}

postfix operator ≈!

public postfix func ≈!(_ node: Node) -> Double {
    return (node≈)!
}

postfix operator &

public postfix func &(_ str: String) -> Variable {
    return try! Variable(str)
}
