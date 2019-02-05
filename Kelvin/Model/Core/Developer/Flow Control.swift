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
        .binary(.if, [.any, .tuple]) {
            let node = try $0.simplify()
            guard let predicament = node as? Bool else {
                return nil
            }
            let tuple = $1 as! Tuple
            
            return try (predicament ? tuple.lhs : tuple.rhs).simplify() // Should this be simplified?
        },
        .binary(.if, [.any, .closure]) {
            let node = try $0.simplify()
            guard let predicate = node as? Bool else {
                throw ExecutionError.predicateException
            }
            if predicate {
                let _ = try $1.simplify()
            }
            return KVoid()
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
        .unary(.try, [.tuple]) {
            let tuple = $0 as! Tuple
            do {
                return try tuple.lhs.simplify()
            } catch {
                return try tuple.rhs.simplify()
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
        .init(.for, [.tuple, .closure]) {
            guard let tuple = $0[0] as? Tuple, let closure = $0[1] as? Closure else {
                throw ExecutionError.general(errMsg: "invalid for loop construct")
            }
            
            guard let v = tuple.lhs as? Variable else {
                let msg = "variable name expected in lhs of \"\(tuple.stringified)\", but found \"\(tuple.lhs.stringified)\" instead."
                throw ExecutionError.general(errMsg: msg)
            }
            
            guard let list = try tuple.rhs.simplify() as? ListProtocol else {
                let msg = "list expected in rhs of \"\(tuple.stringified)\", but found \"\(tuple.rhs.stringified)\" instead"
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
                    print($0)
                    throw ExecutionError.predicateException
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
    ]
}
