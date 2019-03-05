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
    case closure
    case type
    
    public var description: String {
        return rawValue
    }
    
    static let symbol = "@"
    
    public static func resolve<T>(_ type: T.Type) throws -> DataType {
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
        } else if type == DataType.self {
            return .type
        }
        throw ExecutionError.general(errMsg: "\(String(describing: type)) is not a valid type")
    }
    
    /// - Todo: Resolve conflict b/w Number and Int
    public static func resolve(_ node: Node) throws -> DataType {
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
        } else if node is DataType {
            return .type
        }
        throw ExecutionError.general(errMsg: "unable to resolve type of \(node)")
    }
}

/**
 This enum is used to represent specify parameter type requirement.
 By giving a function a name, the number of arguments,
 and the types of arguments, we can generate a unique signature
 that is used later to find definitions.
 */
public enum ParameterType: Int, Equatable {
    case int = 1
    case number
    case nan
    case `var`
    case type
    case `func`
    case closure
    case bool
    case equation
    case string
    case vec
    case matrix
    case list
    case pair
    case iterable
    case leaf
    case any = 100
    case numbers = 1000
    case booleans = 1001
    case multivariate = 4000 // Takes in more than 1 argument
    case universal = 10000 // Takes in any # of args.
    
    var name: String {
        return String(describing: self)
    }
    
    static func resolve<T>(_ type: T.Type) throws -> ParameterType {
        if type == KString.self {
            return .string
        } else if type == List.self {
            return .list
        } else if type == ListProtocol.self || type == MutableListProtocol.self {
            return .iterable
        } else if type == Int.self {
            return .int
        } else if type == Value.self {
            return .number
        } else if type == Variable.self {
            return .var
        } else if type == Vector.self {
            return .vec
        } else if type == Matrix.self {
            return .matrix
        } else if type == Equation.self {
            return .equation
        } else if type == Pair.self {
            return .pair
        } else if type == Function.self {
            return .func
        } else if type == Bool.self {
            return .bool
        } else if type == Node.self {
            return .any
        } else if type == Closure.self {
            return .closure
        } else if type == DataType.self {
            return .type
        }
        throw ExecutionError.general(errMsg: "\(String(describing: type)) is not a valid type")
    }
}
