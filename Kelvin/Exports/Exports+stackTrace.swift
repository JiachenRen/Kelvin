//
//  Exports+stackTrace.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let stackTrace = StackTrace.exports
}

extension StackTrace {

    static let exports: [Operation] = [
        .init(.printStackTrace, []) { _ in
            Program.shared.io?.println(KString(StackTrace.shared.genStackTrace()))
            return KVoid()
        },
        .init(.clearStackTrace, []) { _ in
            StackTrace.shared.clear()
            Program.shared.io?.println(KString("stack trace history has been cleared."))
            return KVoid()
        },
        .unary(.setStackTraceEnabled, Bool.self) {
            StackTrace.shared.isEnabled = $0
            let enabled = $0 ? "enabled" : "disabled"
            Program.shared.io?.println(KString("stack trace \(enabled)"))
            return KVoid()
        },
        .unary(.setStackTraceUntracked, List.self) {
            let untracked = try Assert.specialize(list: $0, as: KString.self).map {$0.string}.filter {
                let isDefined = Operation.registered.keys.contains($0)
                if (!isDefined) {
                    Program.shared.io?.println(KString("warning - \($0) is undefined"))
                }
                return isDefined
            }
            Program.shared.io?.println(KString("untracked \(untracked)"))
            StackTrace.shared.untracked = untracked
            return KVoid()
        }
    ]
}
