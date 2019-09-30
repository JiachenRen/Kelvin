//
//  FlowControl.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// `FlowControl` is an enum that implements `Error` protocol.
/// Its four cases, `continue`, `break`, `return`, `throw` are used for flow control,
/// for instance, jumping out of a loop, a function, or throwing an error
public enum FlowControl: Error {
    /// When `continue` is thrown, it can only be captured by **loops**.,
    /// For instance, `for` loop and `while` loops
    case `continue`
    
    /// When `break` is thrown, it can only be captured by **loops**.,
    case `break`
    
    /// When `return` is thrown, it can only be captured by **closures** or **functions**.
    /// - node: Node to return
    case `return`(_ node: Node)
    
    /// When `throw` is thrown, it can only be captured by `try` blocks.
    /// - node: Node to throw
    case `throw`(_ node: Node)
    
    /// Parses `keyword` into either `.return`, `.throw`, `.continue`, or `.break`
    static func parse(_ keyword: String) -> Function? {
        switch keyword {
        case "continue":
            return Function(.continue, [])
        case "break":
            return Function(.break, [])
        case "return":
            return Function(.return, [KVoid()])
        case "throw":
            return Function(.throw, [KVoid()])
        default:
            return nil
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .continue:
            return "keyword \"continue\" can only be used inside loops"
        case .break:
            return "keyword \"break\" can only be used inside loops"
        case .return(let n):
            return "return from non-function scope: \(n.stringified)"
        case .throw(let n):
            return "error raised at top level: \(n.stringified)"
        }
    }
}
