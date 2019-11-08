//
//  CompilerError.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Errors that occur during the compilation phase such as any bad syntax or
/// an incorrect number of arguments supplied to reserved binary/unary operations
indirect public enum CompilerError: KelvinError {
    case illegalArgument(errMsg: String)
    case syntax(errMsg: String)
    case noSuchConstant(literal: String)
    case invalidType(literal: String)
    case on(line: Int, _ err: CompilerError)
    case cancelled
    case duplicateKeyword(_ name: String)
    case emptyString
    
    public var localizedDescription: String {
        switch self {
        case .illegalArgument(errMsg: let msg):
            return "illegal argument: \(msg)"
        case .syntax(errMsg: let msg):
            return "syntax: \(msg)"
        case .on(line: let i, let e):
            return "error on line \(i) - \(e.localizedDescription)"
        case .cancelled:
            return "compilation has been cancelled"
        case .noSuchConstant(literal: let n):
            return "\(n) is not a constant"
        case .invalidType(literal: let l):
            return "\(l) is not a valid type literal"
        case .duplicateKeyword(let n):
            return "syntax definition for \(n) already exists; please remove it first or choose another keyword"
        case .emptyString:
            return "compiling an empty string"
        }
    }
}
