//
//  Exports+prepositions.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/7/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let pair: [Operation] = [
        Pair.Preposition.allCases.map { pre in
            Operation.binary(pre.rawValue, [Parameter(.node, multiplicity: .count(2))]) {
                Pair($0, $1, preposition: pre)
            }
        },
        Pair.grammar.map { (name, prepMap) in
            Operation.unary(name, Pair.self) { pair in
                try prepMap[pair.prepositionList()]?(pair)
            }
        }
    ].flatMap { $0 }
}
