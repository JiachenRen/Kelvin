//
//  Exports+pair.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let pair: [Operation] = [
        .binary(.pair, [.node, .node]) {
            Pair($0, $1)
        },
        .binary(.get, Pair.self, Int.self) { (pair, idx) in
            switch idx {
            case 0:
                return pair.lhs
            case 1:
                return pair.rhs
            default:
                throw ExecutionError.indexOutOfBounds(
                    maxIdx: 1,
                    idx: idx
                )
            }
        }
    ]
}


