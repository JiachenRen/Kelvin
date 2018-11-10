//
//  Node.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol Node: CustomStringConvertible {
    var numericVal: Double? {get}
    func simplify() -> Node
}

public protocol LeafNode: Node {
}

extension LeafNode {
    func simplify() -> Node {
        return self
    }
}

typealias NumericBin = (Double, Double) -> Double

func unwrap(_ lhs: Node?, _ rhs: Node?, _ compute: NumericBin) -> Double? {
    if let a = lhs?.numericVal, let b = rhs?.numericVal {
        return compute(a, b)
    }
    return nil
}

func +(lhs: Node?, rhs: Node?) -> Node? {
    return unwrap(lhs, rhs, +)
}

func -(lhs: Node?, rhs: Node?) -> Node? {
    return unwrap(lhs, rhs, -)
}

func *(lhs: Node?, rhs: Node?) -> Node? {
    return unwrap(lhs, rhs, *)
}

func /(lhs: Node?, rhs: Node?) -> Node? {
    return unwrap(lhs, rhs, /)
}

func ^(lhs: Node?, rhs: Node?) -> Node? {
    return unwrap(lhs, rhs, pow)
}

func %(lhs: Node?, rhs: Node?) -> Node? {
    return unwrap(lhs, rhs){$0.truncatingRemainder(dividingBy: $1)}
}

func >(lhs: Node?, rhs: Node?) -> Node? {
    if let a = lhs?.numericVal, let b = rhs?.numericVal {
        return a > b
    }
    return nil
}

func <(lhs: Node?, rhs: Node?) -> Node? {
    if let a = lhs?.numericVal, let b = rhs?.numericVal {
        return a < b
    }
    return nil
}

