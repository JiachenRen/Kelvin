//
//  ExecutionError.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Errors thrown during execution of compiled Kelvin AST.
public enum ExecutionError: KelvinError {
    case general(errMsg: String)
    case onLine(_ line: Int, err: KelvinError)
    case onNode(_ node: Node, err: KelvinError)
    case cancelled
    case undefined(_ v: Variable)
    case unexpected
    case invalidType(invalidTypeLiteral: String)
    case unexpectedType(expected: KType, found: KType)
    case indexOutOfBounds(maxIdx: Int, idx: Int)
    case dimensionMismatch(_ a: Node, _ b: Node)
    case domain(_ val: Number, lowerBound: Number, upperBound: Number)
    case invalidRange(lowerBound: Number, upperBound: Number)
    case invalidSubscript(_ target: Node, _ subscript: Node)
    case invalidCast(from: Node, to: KType)
    case invalidDimension(rows: Int, cols: Int)
    case nonUniform
    case circularDefinition
    case nonSquareMatrix
    case emptyMatrix
    case singularMatrix
    case unsupportedPlatform(_ supported: String)
    case stackOverflow(_ stacks: Int)
    case resolved(_ errMsg: String)
    case invalidPolynomial(_ term: Node)
    case invalidOption(_ option: String)
    
    /// Maximum number of error stacks to unravel.
    /// In case of stack overflow, it'll take forever to generate error messages if this were not in place!
    public static let maxStackTrace = 500
    
    /// Resolves the root cause of `err` by recursively looking at its child errors.
    /// - Parameter err: A top level error.
    /// - Returns: The root cause of the error.
    public static func getRootCause(_ err: KelvinError) -> KelvinError {
        guard let execErr = err as? ExecutionError else {
            return err
        }
        switch execErr {
        case .onLine(_, err: let e), .onNode(_, err: let e):
            if let execErr = e as? ExecutionError {
                return getRootCause(execErr)
            }
            return e
        default:
            return execErr
        }
    }
    
    /// Generates stack trace with `self` as the entry point.
    /// - Parameter maxDepth: Defaults to `Int.max`. Maximum number of stacks to go down.
    public func stackTrace(_ maxDepth: Int = .max) -> String {
        if maxDepth == 0 {
            let msg = ExecutionError.getRootCause(self).localizedDescription
            let numOmitted = Program.shared.config.maxStackSize - ExecutionError.maxStackTrace
            return msg + "\n\t... (\(numOmitted) omitted)"
        }
        switch self {
        case .onNode(let n, err: let e):
            let location = "\n\tat \(n.stringified)"
            if let execErr = e as? ExecutionError {
                let trace = execErr.stackTrace(maxDepth - 1)
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
            return stackTrace(ExecutionError.maxStackTrace)
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
            let nodeType = KType.resolve(node).rawValue
            return "cannot cast `\(node.stringified)` of type \(nodeType) to \(type)"
        case .invalidDimension(rows: let r, cols: let c):
            return "(rows: \(r), cols: \(c)) is not a valid dimension"
        case .circularDefinition:
            return "circular definition"
        case .nonSquareMatrix:
            return "non-square matrix"
        case .nonUniform:
            return "the given lists have different lengths"
        case .emptyMatrix:
            return "cannot create an empty matrix"
        case .undefined(let v):
            return "'\(v.name)' is undefined"
        case .unsupportedPlatform(let supported):
            return "this feature is supported on \(supported) only"
        case .singularMatrix:
            return "the given matrix is singular"
        case .stackOverflow(let i):
            return "stack overflow - max stack size of \(i) has been exceeded"
        case .resolved(let s):
            return s
        case .invalidPolynomial(let n):
            return "\(n.stringified) is not a proper polynomial term"
        case .invalidOption(let s):
            return "\(s) is not a valid option"
        }
    }
}
