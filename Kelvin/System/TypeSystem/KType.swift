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
    case type
    case unknown
    
    /// Symbol  used to represent a type in Kelvin script. For instance, String would be `@string`
    static let symbol = "@"
    
    static func resolve<T>(_ type: T.Type) -> KType {
        if let n = type as? Node.Type {
            return n.kType
        }
        return .unknown
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
            if let str = node as? KString {
                return List(str.string.map { KString(String($0)) })
            } else if let list = node as? ListProtocol {
                return List(list.elements)
            }
            throw ExecutionError.invalidCast(from: node, to: type)
        case .vector:
            if let list = node as? ListProtocol {
                return Vector(list)
            }
            throw ExecutionError.invalidCast(from: node, to: type)
        case .matrix:
            let list = try Assert.cast(node, to: Iterable.self)
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
    
    public var description: String { rawValue }
}
