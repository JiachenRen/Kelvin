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
    case on(line: Int, err: KelvinError)
    case cancelled
    case unexpected(_ node: Node?)
    case invalidType(_ node: Node?, invalidTypeLiteral: String)
    case unexpectedType(_ node: Node?, expected: DataType, found: DataType)
    case indexOutOfBounds(_ node: Node?, maxIdx: Int, idx: Int)
    case dimensionMismatch(_ a: Node, _ b: Node)
    case domain(_ node: Node?, _ val: Value, lowerBound: Value, upperBound: Value)
    case invalidRange(_ node: Node?, lowerBound: Value, upperBound: Value)
    case invalidSubscript(_ node: Node?, _ target: Node, _ subscript: Node)
    case invalidCast(from: Node, to: DataType)
    
    private func err(on node: Node?, _ errMsg: String) -> String {
        return "error when executing statement `\(node?.stringified ?? "")`: \(errMsg)"
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
        case .cancelled:
            return "program execution has been cancelled"
        case .unexpected(let node):
            return err(on: node, " an unexpected error has occurred")
        case .invalidType(let node, invalidTypeLiteral: let literal):
            return err(on: node, "`\(literal)` is not a valid type")
        case .unexpectedType(let node, let expected, let found):
            return "error: expected \(expected) in `\(node?.stringified ?? "")`, but found \(found) instead"
        case .indexOutOfBounds(let node, maxIdx: let maxIdx, idx: let idx):
            return err(on: node, "index out of bounds; max index is \(maxIdx), but an index of \(idx) is given")
        case .dimensionMismatch(let a, let b):
            return "error: dimension mismatch in \(a.stringified) and \(b.stringified)"
        case .domain(let node, let val, lowerBound: let lb, upperBound: let ub):
            return err(on: node, "expecting an input between \(lb) and \(ub), but found \(val)")
        case .invalidSubscript(let node, let target, let sub):
            return err(on: node, "cannot subscript \(target.stringified) by \(sub.stringified)")
        case .invalidRange(let node, lowerBound: let lb, upperBound: let ub):
            return err(on: node, "cannot form range from \(lb) to \(ub)")
        case .invalidCast(from: let node, to: let type):
            let nodeType = (try? DataType.resolve(node).description) ?? "unknown"
            return "error: cannot convert node from `\(node.stringified)` aka. \(nodeType) to \(type)"
        }
    }
}

public class Constraint {
    public static func domain(
        at node: Node? = nil,
        _ x: Value,
        _ lb: Value,
        _ ub: Value) throws {
        if x≈! < lb≈! || x≈! > ub≈!  {
            throw ExecutionError.domain(
                node,
                x,
                lowerBound: lb,
                upperBound: ub)
        }
    }
    
    public static func range(
        at node: Node? = nil,
        _ lb: Value,
        _ ub: Value) throws {
        if lb≈! > ub≈! {
            throw ExecutionError.invalidRange(
                node,
                lowerBound: lb,
                upperBound: ub)
        }
    }
    
    public static func index(
        at node: Node? = nil,
        _ count: Int,
        _ idx: Int) throws {
        if idx >= count || idx < 0 {
            throw ExecutionError.indexOutOfBounds(
                node,
                maxIdx: count - 1,
                idx: idx
            )
        }
    }
}
