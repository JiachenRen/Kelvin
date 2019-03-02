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
        .unary(.def, Equation.self) {
            try $0.define()
            return KString("done")
        },
        .unary(.def, Function.self) {
            var fun = $0
            var closure = try Assert.cast(fun.elements.last, to: Closure.self)
            fun.elements.removeLast()
            closure.capturesReturn = true
            try fun.implement(using: closure)
            return KString("done")
        },
        .binary(.define, [.any, .any]) {
            return Function(.def, [Equation(lhs: $0, rhs: $1)])
        },
        .unary(.del, Variable.self) {v in
            Variable.delete(v.name)
            Operation.remove(v.name)
            return KString("deleted '\(v.stringified)'")
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
        .binary(.mutatingConcat, Variable.self, Node.self) {(v, n) in
            try Equation(lhs: v, rhs: Function(.concat, [v, n]))
                .define()
            return v
        },
    ]
    
    private static func assign(_ value: Node, to node: Node, by bin: Binary) throws -> Node {
        assert(node is Variable)
        try Equation(lhs: node, rhs: bin(node, value)).define()
        return node
    }
}
