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
            let predicate = try Assert.cast($0.simplify(), to: Bool.self)
            let pair = $1 as! Pair
            
            return predicate ? pair.lhs : pair.rhs
        },
        .binary(.if, [.any, .any]) {
            let predicate = try Assert.cast($0.simplify(), to: Bool.self)
            if predicate {
                let _ = try $1.simplify()
                return true
            }
            return KVoid()
        },
        .binary(.else, [.func, .any]) {
            let fun = try Assert.cast($0, to: Function.self)
            guard fun.name == .if || fun.name == .else else {
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
            let pair = try Assert.cast($0[0], to: Pair.self)
            let closure = try Assert.cast($0[1], to: Closure.self)
            let v = try Assert.cast(pair.lhs, to: Variable.self)
            let list = try Assert.cast(pair.rhs.simplify(), to: ListProtocol.self)
            
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
            let closure = try Assert.cast($1, to: Closure.self)
            loop: while true {
                if !(try Assert.cast($0.simplify(), to: Bool.self)) {
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
