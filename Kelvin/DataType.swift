//
//  Keyword.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public enum DataType: String, CustomStringConvertible {
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
    
    public var description: String {
        return rawValue
    }
    
    static func resolve<T>(_ type: T.Type) throws -> DataType {
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
        }
        throw ExecutionError.general(errMsg: "\(String(describing: type)) is not a valid type")
    }
    
    /// - Todo: Resolve conflict b/w Number and Int
    static func resolve(_ node: Node) throws -> DataType {
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
        }
        throw ExecutionError.general(errMsg: "unable to resolve type of \(node)")
    }
}
