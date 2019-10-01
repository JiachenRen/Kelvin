//
//  KString+Supplier.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension KString: Supplier {
    static let exports: [Operation] = [
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
        
        // Replace
        .ternary(.replace, KString.self, KString.self, KString.self) {
            KString($0.string.replacingOccurrences(of: $1.string, with: $2.string))
        },
        
        // Contains
        .binary(.contains, KString.self, KString.self) {
            $0.string.contains($1.string)
        },
        
        // Regex
        .ternary(.regexReplace, KString.self, KString.self, KString.self) {
            KString($0.string.replacingOccurrences(of: $1.string, with: $2.string, options: .regularExpression))
        },
        .binary(.regexMatches, KString.self, KString.self) {
            let reg = try NSRegularExpression(pattern: $1.string)
            let str = $0.string
            let range = NSRange(str.startIndex..., in: str)
            let matches = reg.matches(in: str, range: range).map {
                KString(String(str[Range($0.range, in: str)!]))
            }
            return List(matches)
        }
    ]
}
