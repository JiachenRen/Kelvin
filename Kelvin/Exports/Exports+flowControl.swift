//
//  Exports+flowControl.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let flowControl = FlowControl.exports
}

extension FlowControl {
    
    // Bridge flow control operations
    static let exports: [Operation] = [
        
        // Pileline, conditional statements
        .binary(.ternaryConditional, Node.self, Pair.self) {(n, pair) in
            let predicate = try n.simplify()
            if let bool = predicate as? Bool {
                return bool ? pair.lhs : pair.rhs
            }
            return nil
        },
        .binary(.if, [.node, .node]) {
            let predicate = try $0.simplify()
            if let bool = predicate as? Bool {
                if bool {
                    let _ = try $1.simplify()
                    return true
                }
                return false
            }
            return nil
        },
        .binary(.else, Function.self, Node.self) {(fun, rhs) in
            guard fun.name == .if || fun.name == .else else {
                throw ExecutionError.general(errMsg: "left hand side of 'else' must be a if statement or else statement")
            }
            guard (rhs as? Function)?.name == .if || rhs is Closure else {
                throw ExecutionError.general(errMsg: "right hand side of 'else' must be a if statement or closure")
            }
            // Resolve preceding if clause.
            let prevResult = try fun.simplify()
            if let wasTrue = prevResult as? Bool {
                if wasTrue {
                    // Previous clause has been executed. Return immediately.
                    return true
                } else {
                    // Previous clause was not executed, try the next if clause.
                    return try rhs.simplify()
                }
            }
            // Previous if clause was not resolved.
            return nil
        },
        .binary(.pipe, [.node, .node]) {
            let simplified = try $0.simplify()
            return $1.replacingAnonymousArgs(with: [simplified])
        },
        
        // Transfer
        .unary(.return, [.node]) {
            throw FlowControl.return($0)
        },
        .init(.break, []) {_ in
            throw FlowControl.break
        },
        .init(.continue, []) {_ in
            throw FlowControl.continue
        },
        
        // Error handling
        .unary(.throw, [.node]) {
            throw ExecutionError.general(errMsg: $0.stringified)
        },
        .unary(.try, Pair.self) {
            do {
                return try $0.lhs.simplify()
            } catch {
                return try $0.rhs.simplify()
            }
        },
        .unary(.try, [.node]) {
            do {
                return try $0.simplify()
            } catch let e as KelvinError {
                return String(e.localizedDescription)
            }
        },
        .unary(.assert, Node.self) {
            let predicate = try Assert.cast($0, to: Bool.self)
            if !predicate {
                throw ExecutionError.general(errMsg: "assertion failed")
            }
            return true
        },
        .binary(.assertEquals, Node.self, Node.self) {
            try Assert.equals($0, $1, message: "assertion failed: expected")
            return true
        },
        
        // Loops
        .binary(.for, Pair.self, Closure.self) {(pair, closure) in
            let v = try Assert.cast(pair.lhs, to: Variable.self)
            let list = try Assert.cast(pair.rhs.simplify(), to: ListProtocol.self)
            loop: for e in list.elements {
                let def = Variable.definitions[v.name]
                Variable.define(v.name, e)
                do {
                    let _ = try closure.simplify()
                } catch let c as FlowControl {
                    switch c {
                    case .continue:
                        continue
                    case .break:
                        break loop
                    default:
                        throw c
                    }
                }
                Variable.definitions[v.name] = def
            }
            return KVoid()
        },
        .binary(.while, Node.self, Closure.self) {(predicate, closure) in
            loop: while true {
                if !(try Assert.cast(predicate.simplify(), to: Bool.self)) {
                    break
                }
                
                do {
                    let _ = try closure.simplify()
                } catch let c as FlowControl {
                    switch c {
                    case .continue:
                        continue
                    case .break:
                        break loop
                    default:
                        throw c
                    }
                }
            }
            return KVoid()
        },
        .ternary(.stride, Number.self, Number.self, Number.self) {
            var lb = $0.float80, ub = $1.float80, step = $2.float80
            var elements = [Node]()
            while lb <= ub {
                elements.append(lb)
                lb += step
            }
            return Vector(elements)
        }
    ]
}
