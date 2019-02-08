//
//  Assignment.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Developer {

    /// Variable/function definition and deletion;
    /// increment, decrement, assignment...
    static let assignmentOperations: [Operation] = [
        
        .unary(.def, [.equation]) {
            guard let eq = $0 as? Equation else {
                throw ExecutionError.general(errMsg: "cannot create definition using \($0.stringified) as template.")
            }
            try eq.define()
            return KString("done")
        },
        .unary(.def, [.func]) {
            guard var fun = $0 as? Function else {
                throw ExecutionError.general(errMsg: "cannot create definition using \($0.stringified) as template.")
            }
            guard var closure = fun.elements.last as? Closure else {
                let msg = "last element in function \($0.stringified) must be a closure to be used as definition"
                throw ExecutionError.general(errMsg: msg)
            }
            fun.elements.removeLast()
            closure.capturesReturn = true
            try fun.implement(using: closure)
            return KString("done")
        },
        .binary(.define, [.any, .any]) {
            return Function(.def, [Equation(lhs: $0, rhs: $1)])
        },
        .unary(.del, [.var]) {
            if let v = $0 as? Variable {
                Variable.delete(v.name)
                Operation.remove(v.name)
                return KString("deleted '\(v.stringified)'")
            }
            return nil
        },
        
        // C like assignment shorthand
        .unary(.increment, [.var]) {
            $0 +== 1
        },
        .unary(.decrement, [.var]) {
            $0 -== 1
        },
        .binary(.mutatingAdd, [.var, .any]) {
            try assign($1, to: $0, by: +)
        },
        .binary(.mutatingSub, [.var, .any]) {
            try assign($1, to: $0, by: -)
        },
        .binary(.mutatingMult, [.var, .any]) {
            try assign($1, to: $0, by: *)
        },
        .binary(.mutatingDiv, [.var, .any]) {
            try assign($1, to: $0, by: /)
        },
    ]
    
    private static func assign(_ value: Node, to node: Node, by bin: Binary) throws -> Node {
        assert(node is Variable)
        try Equation(lhs: node, rhs: bin(node, value)).define()
        return node
    }
}
