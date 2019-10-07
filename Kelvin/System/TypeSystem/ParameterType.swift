//
//  ParameterType.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// `ParameterType` is used to represent specify parameter type requirement. By giving a function a name,
/// the number of arguments, and the types of arguments, we can generate a unique signature that is used later to find definitions.
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
    case leaf
    case iterable = 50
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
        } else if type == KType.self {
            return .type
        } else if type == Iterable.self {
            return .iterable
        }
        throw ExecutionError.general(errMsg: "\(String(describing: type)) is not a kelvin type")
    }
}
