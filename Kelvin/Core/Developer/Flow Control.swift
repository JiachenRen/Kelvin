//
//  Conditional Statements.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Developer {
    static let flowControlOperations: [Operation] = [
        
        // Pileline, conditional statements
        .binary(.ternaryConditional, [.any, .pair]) {
            let node = try $0.simplify()
            guard let predicament = node as? Bool else {
                return nil
            }
            let pair = $1 as! Pair
            
            return try (predicament ? pair.lhs : pair.rhs).simplify() // Should this be simplified?
        },
        .binary(.if, [.any, .closure]) {
            let node = try $0.simplify()
            guard let predicate = node as? Bool else {
                throw ExecutionError.unexpectedType(
                    Function(.if, [$0, $1]),
                    expected: .bool,
                    found: try .resolve($1)
                )
            }
            if predicate {
                let _ = try $1.simplify()
                return true
            }
            return KVoid()
        },
        .binary(.else, [.func, .any]) {
            guard let name = ($0 as? Function)?.name, name == .if || name == .else else {
                throw ExecutionError.general(errMsg: "left hand side of 'else' must be a if statement or else statement")
            }
            
            guard ($1 as? Function)?.name == .if || $1 is Closure else {
                throw ExecutionError.general(errMsg: "right hand side of 'else' must be a if statement or closure")
            }
            
            if try $0.simplify() === true {
                return true
            } else {
                return try $1.simplify()
            }
        },
        .binary(.pipe, [.any, .any]) {
            let simplified = try $0.simplify()
            return $1.replacingAnonymousArgs(with: [simplified])
        },
        
        // Transfer
        .unary(.return, [.any]) {
            throw Transfer.return($0)
        },
        .init(.break, []) {_ in
            throw Control.break
        },
        .init(.continue, []) {_ in
            throw Control.continue
        },
        
        // Error handling
        .unary(.throw, [.any]) {
            throw ExecutionError.general(errMsg: $0.stringified)
        },
        .unary(.try, [.pair]) {
            let pair = $0 as! Pair
            do {
                return try pair.lhs.simplify()
            } catch {
                return try pair.rhs.simplify()
            }
        },
        .unary(.try, [.any]) {
            do {
                return try $0.simplify()
            } catch let e as KelvinError {
                return KString(e.localizedDescription)
            }
        },
        .unary(.assert, [.bool]) {
            if !($0 as! Bool) {
                throw ExecutionError.general(errMsg: "assertion failed")
            }
            return true
        },
        
        // Loops
        .init(.for, [.pair, .closure]) {
            guard let pair = $0[0] as? Pair, let closure = $0[1] as? Closure else {
                throw ExecutionError.general(errMsg: "invalid for loop construct")
            }
            
            guard let v = pair.lhs as? Variable else {
                let msg = "variable name expected in lhs of \"\(pair.stringified)\", but found \"\(pair.lhs.stringified)\" instead."
                throw ExecutionError.general(errMsg: msg)
            }
            
            guard let list = try pair.rhs.simplify() as? ListProtocol else {
                let msg = "list expected in rhs of \"\(pair.stringified)\", but found \"\(pair.rhs.stringified)\" instead"
                throw ExecutionError.general(errMsg: msg)
            }
            
            loop: for e in list.elements {
                let def = Variable.definitions[v.name]
                Variable.define(v.name, e)
                do {
                    let _ = try closure.simplify()
                } catch let c as Control {
                    switch c {
                    case .continue:
                        continue
                    case .break:
                        break loop
                    }
                }
                Variable.definitions[v.name] = def
            }
            
            return KVoid()
        },
        .binary(.while, [.any, .closure]) {
            guard let closure = $1 as? Closure else {
                throw ExecutionError.general(errMsg: "invalid while loop construct")
            }
            
            loop: while true {
                guard let b = try $0.simplify() as? Bool else {
                    throw ExecutionError.unexpectedType(
                        Function(.while, [$0, $1]),
                        expected: .bool,
                        found: try .resolve($0.simplify())
                    )
                }
                if !b {
                    break
                }
                
                do {
                    let _ = try closure.simplify()
                } catch let c as Control {
                    switch c {
                    case .continue:
                        continue
                    case .break:
                        break loop
                    }
                }
            }
            return KVoid()
        },
        .init(.stride, [.number, .number, .number]) {
            var elements = [Node]()
            var args = $0.map {Double($0≈!)}
            while args[0] <= args[1] {
                elements.append(Float80(args[0]))
                args[0] += args[2]
            }
            return List(elements)
        }
    ]
}
