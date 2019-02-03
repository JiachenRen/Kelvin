//
//  Error.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/7/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol KelvinError: Error {
    var localizedDescription: String { get }
}

/// Errors that occur during the compilation phase such as any bad syntax or
/// an incorrect number of arguments supplied to reserved binary/unary operations
indirect public enum CompilerError: KelvinError {
    case illegalArgument(errMsg: String)
    case syntax(errMsg: String)
    case on(line: Int, _ err: CompilerError)
    
    public var localizedDescription: String {
        switch self {
        case .illegalArgument(errMsg: let msg):
            return "illegal argument: \(msg)"
        case .syntax(errMsg: let msg):
            return "syntax: \(msg)"
        case .on(line: let i, let e):
            return "error on line \(i) - \(e.localizedDescription)"
        }
    }
}

public enum ExecutionError: KelvinError {
    static let indexOutOfBounds = ExecutionError.general(errMsg: "index out of bounds")
    static let dimensionMismatch = ExecutionError.general(errMsg: "dimension mismatch")
    static let predicateException = ExecutionError.general(errMsg: "predicate must be a boolean")
    static let unexpectedError = ExecutionError.general(errMsg: "an unexpected error has occurred")
    
    case general(errMsg: String)
    case on(line: Int, err: KelvinError)
    
    static func invalidDT(_ invalid: String) -> ExecutionError {
        return ExecutionError.general(errMsg: "invalid data type '\(invalid)'")
    }
    
    static func inconvertibleDT(from d1: String, to d2: String) -> ExecutionError {
        return ExecutionError.general(errMsg: "cannot convert \(d1) to \(d2)")
    }
    
    static func incompatibleList(_ requiredType: DataType) -> ExecutionError {
        return ExecutionError.general(errMsg: "every element in the list must be a \(requiredType)")
    }
    
    static func invalidDomain(_ lb: Double, _ ub: Double) -> ExecutionError {
        return ExecutionError.general(errMsg: "invalid domain - input must be between \(lb) and \(ub)")
    }
    
    static func invalidSubscript(_ target: String, _ sub: String) -> ExecutionError {
        return ExecutionError.general(errMsg: "cannot subscript \(target) by \(sub)")
    }
    
    public var localizedDescription: String {
        switch self {
        case .general(errMsg: let msg):
            return "error: \(msg)"
        case .on(line: let i, err: let e):
            var msg = e.localizedDescription
            if let execErr = e as? ExecutionError {
                switch execErr {
                case .general(errMsg: let errMsg):
                    msg = errMsg
                default:
                    break
                }
            }
            return "error on line \(i) - \(msg)"
        }
    }
}
