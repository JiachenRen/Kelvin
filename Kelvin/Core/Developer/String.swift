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
            guard let s = $0 as? KString, let n = $1 as? Int else {
                return nil
            }
            if n >= s.string.count || n < 0{
                throw ExecutionError.indexOutOfBounds(
                    Function(.get, [$0, $1]),
                    maxIdx: s.string.count - 1,
                    idx: n)
            } else {
                return KString("\(s.string[n])")
            }
        },
    ]
}
