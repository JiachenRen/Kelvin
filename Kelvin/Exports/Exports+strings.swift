//
//  Exports+strings.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let strings: [Operation] = [
        // Splitting a string
        .binary(.split, String.self, String.self) {
            List($0.components(separatedBy: $1)
                .map { String($0) }
            )
        },
        
        // String concatenation
        .binary(.concat, [.node, .node]) {
            $0.stringified + $1.stringified
        },
        .binary(.concat, String.self, Node.self) {
            $0 + $1.stringified
        },
        .binary(.concat, Node.self, String.self) {
            $0.stringified + $1
        },
        .binary(.concat, String.self, String.self) {
            $0 + $1
        },
        
        // String subscript
        .binary(.get, String.self, Int.self) {(s, n) in
            try Assert.index(s.count, n)
            return "\(s[n])"
        },
        .binary(.get, String.self, List.self) {
            (str, idxList) in
            let indices = try Assert.specialize(list: idxList, as: Int.self)
            guard indices.count == 2 else {
                throw ExecutionError.invalidSubscript(str, idxList)
            }
            return String(str[indices[0]..<indices[1]])
        },
        
        // Replace
        .ternary(.replace, String.self, String.self, String.self) {
            $0.replacingOccurrences(of: $1, with: $2)
        },
        
        // Contains
        .binary(.contains, String.self, String.self) {
            $0.contains($1)
        },
        
        .unary(.count, String.self) { $0.count },
        
        // Regex
        .ternary(.regexReplace, String.self, String.self, String.self) {
            $0.replacingOccurrences(of: $1, with: $2, options: .regularExpression)
        },
        .binary(.regexMatches, String.self, String.self) {
            let reg = try NSRegularExpression(pattern: $1)
            let str = $0
            let range = NSRange(str.startIndex..., in: str)
            let matches = reg.matches(in: str, range: range).map {
                String(String(str[Range($0.range, in: str)!]))
            }
            return List(matches)
        },
        
        // Utilities
        .unary(.lowercased, String.self) { $0.lowercased() },
        .unary(.uppercased, String.self) { $0.uppercased() }
    ]
}
