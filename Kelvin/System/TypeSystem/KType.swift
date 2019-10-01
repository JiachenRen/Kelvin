//
//  KType.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Type in Kelvin. KelvinType -> KType
public enum KType: String, CustomStringConvertible {
    case string
    case list
    case number
    case int
    case variable
    case vector
    case matrix
    case equation
    case pair
    case function
    case bool
    case closure
    case type
    
    public var description: String {
        return rawValue
    }
    
    /// Symbol  used to represent a type in Kelvin script.
    /// For instance, String would be `@string`
    static let symbol = "@"
    
    public static func resolve<T>(_ type: T.Type) throws -> KType {
        if type == KString.self {
            return .string
        } else if type == List.self || type == ListProtocol.self || type == MutableListProtocol.self {
            return .list
        } else if type == Int.self {
            return .int
        } else if type == Float80.self || type == Value.self {
            return .number
        } else if type == Variable.self {
            return .variable
        } else if type == Vector.self {
            return .vector
        } else if type == Matrix.self {
            return .matrix
        } else if type == Equation.self {
            return .equation
        } else if type == Pair.self {
            return .pair
        } else if type == Function.self {
            return .function
        } else if type == Bool.self {
            return .bool
        } else if type == Closure.self {
            return .closure
        } else if type == KType.self {
            return .type
        }
        throw ExecutionError.general(errMsg: "\(String(describing: type)) is not a valid type")
    }
    
    /// - Todo: store relevant type info in their own class definition.
    public static func resolve(_ node: Node) throws -> KType {
        if node is KString {
            return .string
        } else if node is List {
            return .list
        } else if node is Int {
            return .int
        } else if node is Value {
            return .number
        } else if node is Variable {
            return .variable
        } else if node is Vector {
            return .vector
        } else if node is Matrix {
            return .matrix
        } else if node is Equation {
            return .equation
        } else if node is Pair {
            return .pair
        } else if node is Function {
            return .function
        } else if node is Bool {
            return .bool
        } else if node is KType {
            return .type
        }
        throw ExecutionError.general(errMsg: "unable to resolve type of \(node)")
    }
    
    /// Converts `node` to `type`.
    /// Supported casts:
    /// `@iterable ->  @list` (only 1 level)
    /// `@iterable ->  @vector`  (only 1 level)
    /// `@iterable ->  @matrix`  (2 levels)
    /// `@string   ->  @variable`
    /// `@string   ->  @number`
    /// - Todo: Implement all possible type coersions.
    public static func convert(_ node: Node, to type: KType) throws -> Node {
        switch type {
        case .list:
            if let list = List(node) {
                return list
            }
            throw ExecutionError.invalidCast(from: node, to: type)
        case .vector:
            if let vec = Vector(node) {
                return vec
            }
            throw ExecutionError.invalidCast(from: node, to: type)
        case .matrix:
            let list = try Assert.cast(node, to: ListProtocol.self)
            return try Matrix(list)
        case .string:
            return KString(node.stringified)
        case .variable:
            let s = try Assert.cast(node, to: KString.self)
            guard let v = Variable(s.string) else {
                let msg = "illegal variable name \(s.string)"
                throw ExecutionError.general(errMsg: msg)
            }
            return v
        case .number:
            let s = try Assert.cast(node, to: KString.self)
            if let n = Float80(s.string) {
                return n
            }
            throw ExecutionError.general(errMsg: "\(s.stringified) is not a valid number")
        default:
            throw ExecutionError.general(errMsg: "conversion to \(type) is not yet supported")
        }
    }
}
