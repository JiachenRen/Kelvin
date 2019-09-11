//
//  Debug.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/10/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Developer {
    
    // Operations related to debugging
    static let debugOperations: [Operation] = [
        
        // Stack trace
        .init(.printStackTrace, []) { _ in
            Program.io?.println(KString(StackTrace.shared.genStackTrace()))
            return KVoid()
        },
        .init(.clearStackTrace, []) { _ in
            StackTrace.shared.clear()
            Program.io?.println(KString("stack trace history has been cleared."))
            return KVoid()
        },
        .unary(.setStackTraceEnabled, Bool.self) {
            StackTrace.shared.isEnabled = $0
            let enabled = $0 ? "enabled" : "disabled"
            Program.io?.println(KString("stack trace \(enabled)"))
            return KVoid()
        },
        .unary(.setStackTraceUntracked, List.self) {
            let untracked = try Assert.specialize(list: $0, as: KString.self).map {$0.string}.filter {
                let isDefined = Operation.registered.keys.contains($0)
                if (!isDefined) {
                    Program.io?.println(KString("warning - \($0) is undefined"))
                }
                return isDefined
            }
            Program.io?.println(KString("untracked \(untracked)"))
            StackTrace.shared.untracked = untracked
            return KVoid()
        },
        
        // Manage variable/function definitions
        .noArg(.listVariables) {
            Final(node: List(Variable.definitions.keys.compactMap {Variable($0)}))
        },
        .noArg(.clearVariables) {
            Variable.restoreDefault()
            return KVoid()
        },
        .noArg(.listFunctions) {
            List(Operation.userDefined.map {KString($0.description)})
        },
        .noArg(.clearFunctions) {
            Operation.restoreDefault()
            return KVoid()
        },
        
        // Debug utilities
        .unary(.complexity, [.any]) {
            $0.complexity
        },
        .init(.exit, []) { _ in
            exit(0)
        },
        .init(.date, []) { _ in
            KString("\(Date())")
        },
        .init(.time, []) { _ in
            Float80(Date().timeIntervalSince1970)
        },
        .unary(.delay, Value.self) {
            Thread.sleep(forTimeInterval: Double($0.float80))
            return KString("done")
        },
        
        // Measuring performance
        .binary(.measure, Int.self, Node.self) {(i, n) in
            let t = Date().timeIntervalSince1970
            for _ in 0..<i {
                let _ = try n.simplify()
            }
            let avg = Float80(Date().timeIntervalSince1970 - t) / Float80(i)
            return Pair("avg(s)", avg)
        },
        .unary(.measure, [.any]) {
            let t = Date().timeIntervalSince1970
            let _ = try $0.simplify()
            return Float80(Date().timeIntervalSince1970 - t)
        }
        
    ]
}
