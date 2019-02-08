//
//  Transfer.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

enum Transfer: KelvinError {
    case `return`(_ node: Node)
    case `throw`(_ node: Node)
    
    var localizedDescription: String {
        switch self {
        case .return(let n):
            return "return from non-function scope: \(n.stringified)"
        case .throw(let n):
            return "error raised at top level: \(n.stringified)"
        }
    }
    
    static func parse(_ keyword: String) -> Function? {
        switch keyword {
        case "return":
            return Function(.return, [KVoid()])
        case "throw":
            return Function(.throw, [KVoid()])
        default:
            return nil
        }
    }
}

enum Control: KelvinError {
    case `continue`
    case `break`
    
    var localizedDescription: String {
        switch self {
        case .continue:
            return "keyword \"continue\" can only be used inside loops"
        default:
            return "keyword \"break\" can only be used inside loops"
        }
    }
    
    static func parse(_ keyword: String) -> Function? {
        switch keyword {
        case "continue":
            return Function(.continue, [])
        case "break":
            return Function(.break, [])
        default:
            return nil
        }
    }
}
