//
//  Error.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/7/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Errors that occur during the compilation phase such as any bad syntax or
/// an incorrect number of arguments supplied to reserved binary/unary operations
indirect public enum CompilerError: Error {
    case illegalArgument(errMsg: String)
    case syntax(errMsg: String)
    case error(onLine: Int, _ err: CompilerError)
}

public enum ExecutionError: Error {
    static let indexOutOfBounds = ExecutionError.general(errMsg: "index out of bounds")
    static let dimensionMismatch = ExecutionError.general(errMsg: "dimension mismatch")
    static let predicateException = ExecutionError.general(errMsg: "predicate must be a boolean")
    case general(errMsg: String)
    
    static func invalidDT(_ invalid: String) -> ExecutionError {
        return ExecutionError.general(errMsg: "invalid data type '\(invalid)'")
    }
    
    static func inconvertibleDT(from d1: String, to d2: String) -> ExecutionError {
        return ExecutionError.general(errMsg: "cannot convert \(d1) to \(d2)")
    }
}
