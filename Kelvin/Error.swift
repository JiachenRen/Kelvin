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
    case cancelled
    
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
        }
    }
}

public enum ExecutionError: KelvinError {
    case general(errMsg: String)
    case onLine(_ line: Int, err: KelvinError)
    case onNode(_ node: Node, err: KelvinError)
    case cancelled
    case undefined(_ v: Variable)
    case unexpected
    case invalidType(invalidTypeLiteral: String)
    case unexpectedType(expected: DataType, found: DataType)
    case indexOutOfBounds(maxIdx: Int, idx: Int)
    case dimensionMismatch(_ a: Node, _ b: Node)
    case domain(_ val: Value, lowerBound: Value, upperBound: Value)
    case invalidRange(lowerBound: Value, upperBound: Value)
    case invalidSubscript(_ target: Node, _ subscript: Node)
    case invalidCast(from: Node, to: DataType)
    case circularDefinition
    case nonSquareMatrix
    
    private static func getRootCause(_ err: KelvinError) -> String {
        guard let execErr = err as? ExecutionError else {
            return err.localizedDescription
        }
        switch execErr {
        case .onLine(_, err: let e), .onNode(_, err: let e):
            if let execErr = e as? ExecutionError {
                return getRootCause(execErr)
            }
            return e.localizedDescription
        default:
            return execErr.localizedDescription
        }
    }
    
    public func stackTrace() -> String {
        switch self {
        case .onNode(let n, err: let e):
            let location = "\n\tat \(n.stringified)"
            if let execErr = e as? ExecutionError {
                let trace = execErr.stackTrace()
                return trace + location
            }
            return e.localizedDescription + location
        default:
            return localizedDescription
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .general(errMsg: let msg):
            return "\(msg)"
        case .onLine(let i, err: let e):
            return "error on line \(i) - \(e.localizedDescription)"
        case .onNode(_, _):
            return stackTrace()
        case .cancelled:
            return "program execution has been cancelled"
        case .unexpected:
            return "an unexpected error has occurred"
        case .invalidType(invalidTypeLiteral: let literal):
            return "`\(literal)` is not a valid type"
        case .unexpectedType(let expected, let found):
            return "expected \(expected), but found \(found) instead"
        case .indexOutOfBounds(maxIdx: let maxIdx, idx: let idx):
            return "index out of bounds; max index is \(maxIdx), but an index of \(idx) is given"
        case .dimensionMismatch(let a, let b):
            return "dimension mismatch in \(a.stringified) and \(b.stringified)"
        case .domain(let val, lowerBound: let lb, upperBound: let ub):
            return "expecting an input between \(lb) and \(ub), but found \(val)"
        case .invalidSubscript(let target, let sub):
            return "cannot subscript \(target.stringified) by \(sub.stringified)"
        case .invalidRange(lowerBound: let lb, upperBound: let ub):
            return "cannot form range from \(lb) to \(ub)"
        case .invalidCast(from: let node, to: let type):
            let nodeType = (try? DataType.resolve(node).description) ?? "unknown"
            return "cannot cast `\(node.stringified)` of type \(nodeType) to \(type)"
        case .circularDefinition:
            return "circular definition"
        case .nonSquareMatrix:
            return "non-square matrix"
        case .undefined(let v):
            return "'\(v.name)' is undefined"
        }
    }
}
