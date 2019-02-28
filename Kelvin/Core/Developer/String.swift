//
//  String.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Developer {
    static let stringOperations: [Operation] = [
        // Splitting a string
        .binary(.split, [.string, .string]) {
            List(($0 as! KString).string
                .components(separatedBy: ($1 as! KString).string)
                .map {KString($0)}
            )
        },
        
        // String concatenation
        .binary(.concat, [.any, .any]) {
            KString("\($0.stringified)").concat(KString("\($1.stringified)"))
        },
        .binary(.concat, [.string, .any]) {
            ($0 as! KString).concat(KString("\($1.stringified)"))
        },
        .binary(.concat, [.any, .string]) {
            KString("\($0.stringified)").concat($1 as! KString)
        },
        .binary(.concat, [.string, .string]) {
            ($0 as! KString).concat($1 as! KString)
        },
        
        // String subscript
        .binary(.get, [.string, .number]) {
            let s = try Assert.cast($0, to: KString.self)
            let n = try Assert.cast($1, to: Int.self)
            try Assert.index(
                at: Function(.get, [$0, $1]),
                s.string.count,
                n
            )
            return KString("\(s.string[n])")
        },
    ]
}
