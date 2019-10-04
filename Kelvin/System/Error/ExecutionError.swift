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
    case domain(_ val: Value, lowerBound: Value, upperBound: Value)
    case invalidRange(lowerBound: Value, upperBound: Value)
    case invalidSubscript(_ target: Node, _ subscript: Node)
    case invalidCast(from: Node, to: KType)
    case invalidDimension(rows: Int, cols: Int)
    case nonUniform
    case circularDefinition
    case nonSquareMatrix
    case emptyMatrix
    case singularMatrix
    case unsupportedPlatform(_ supported: String)
    
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
            let nodeType = (try? KType.resolve(node).description) ?? "unknown"
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
        }
    }
}
