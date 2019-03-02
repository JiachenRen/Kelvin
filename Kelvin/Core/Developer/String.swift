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
        .binary(.split, KString.self, KString.self) {
            List($0.string.components(separatedBy: $1.string)
                .map {KString($0)}
            )
        },
        
        // String concatenation
        .binary(.concat, [.any, .any]) {
            KString("\($0.stringified)").concat(KString("\($1.stringified)"))
        },
        .binary(.concat, KString.self, Node.self) {
            $0.concat(KString("\($1.stringified)"))
        },
        .binary(.concat, Node.self, KString.self) {
            KString("\($0.stringified)").concat($1)
        },
        .binary(.concat, KString.self, KString.self) {
            $0.concat($1)
        },
        
        // String subscript
        .binary(.get, KString.self, Int.self) {(s, n) in
            try Assert.index(s.string.count, n)
            return KString("\(s.string[n])")
        },
    ]
}
