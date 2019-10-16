//
//  Exports+algebra.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let algebra: [Operation] = Algebra.exports
}

extension Algebra {
    static let exports: [Operation] = [
        .unary(.factor, [.node]) { try factor($0) },
        .unary(.expand, [.node]) { expand($0) },
        .binary(.coefficients, Node.self, Variable.self) {
            try List(coefficients(of: $0, $1).map { d, c in Pair(d, c) })
        }
    ]
}


