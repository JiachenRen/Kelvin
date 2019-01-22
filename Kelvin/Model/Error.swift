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
public enum CompilerError: Error {
    case illegalArgument(errMsg: String)
    case syntax(errMsg: String)
    case error(onLine: Int, _ err: Error)
}

public enum ExecutionError: Error {
    case general(errMsg: String)
}
