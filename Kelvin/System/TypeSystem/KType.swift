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
    
    // Child (level 1) types
    case string
    case list
    case float80
    case int
    case bigInt
    case fraction
    case variable
    case constant
    case vector
    case matrix
    case equation
    case pair
    case function
    case bool
    case kType
    case kVoid
    case closure
    case statements

    // Level 2 types
    case integer
    case iterable
    
    // Level 3 types
    case exact
    case listProtocol
    
    // Level 4 types
    case number
    case naN
    
    // Parent (level 5) type
    case node
    
    // Non-kelvin type
    case unknown
    
    /// Marker for Kelvin types.
    static let marker = "@"
    
    /// Description for the Kelvin type
    public var description: String { "\(KType.marker)\(rawValue)" }
    
    /// The parent of this type, if it exists.
    public var parent: KType? { KType.parent[self]! }
    
    /// Enumeration of the immediate parent of each KType.
    static let parent: [KType: KType?] = [
      // NaN types
      .list: .iterable,
      .vector: .iterable,
      .matrix: .iterable,
      .equation: .iterable,
      .pair: .iterable,
      .iterable: .listProtocol,
      .function: .listProtocol,
      .statements: .listProtocol,
      .listProtocol: .naN,
      .string: .naN,
      .variable: .naN,
      .bool: .naN,
      .kType: .naN,
      .kVoid: .naN,
      .closure: .naN,
      .naN: .node,
      
      // Number types
      .int: .integer,
      .bigInt: .integer,
      .integer: .exact,
      .fraction: .exact,
      .exact: .number,
      .constant: .number,
      .float80: .number,
      .number: .node,
      
      // Parent
      .node: nil,
      .unknown: nil
    ]
    
    /// - Returns: True if `self` is `type` or a child of `type`.
    public func `is`(_ type: KType) -> Bool {
        if self == type {
            return true
        }
        if let p = self.parent {
            return p.is(type)
        }
        return false
    }
    
    /// - Returns: String with first letter lowercased.
    private static func lowerCaseFirst(_ s: String) -> String {
        return String(s[s.startIndex]).lowercased() + s.dropFirst()
    }
    
    /// Maps the given Swift type `T` to a `KType`.
    public static func resolve<T>(_ type: T.Type) -> KType {
        KType(rawValue: lowerCaseFirst(String(describing: type))) ?? .unknown
    }
    
    /// Resolves the `KType` of given Swift instance.
    public static func resolve(_ instance: Any) -> KType {
        KType(rawValue: lowerCaseFirst(String(describing: type(of: instance)))) ?? .unknown
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
            if let str = node as? String {
                return List(str.map { String($0) })
            } else if let list = node as? ListProtocol {
                return List(list.elements)
            }
            throw ExecutionError.invalidCast(from: node, to: type)
        case .vector:
            if let mat = node as? Matrix {
                return try Vector(mat)
            }
            if let list = node as? ListProtocol {
                return Vector(list)
            }
            throw ExecutionError.invalidCast(from: node, to: type)
        case .matrix:
            if let vec = node as? Vector {
                return try Matrix(vec)
            }
            let list = try Assert.cast(node, to: Iterable.self)
            return try Matrix(list)
        case .string:
            return String(node.stringified)
        case .variable:
            let s = try Assert.cast(node, to: String.self)
            guard let v = Variable(s) else {
                let msg = "illegal variable name \(s)"
                throw ExecutionError.general(errMsg: msg)
            }
            return v
        case .number:
            let s = try Assert.cast(node, to: String.self)
            if let n = Float80(s) {
                return n
            }
            throw ExecutionError.general(errMsg: "\(s.stringified) is not a valid number")
        default:
            throw ExecutionError.general(errMsg: "conversion to \(type) is not yet supported")
        }
    }
}
