//
//  Exports+approx.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/21/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let approx: [Operation] = [
        .unary(.approximateFraction, Float80.self) {
            try Approximator.guessFraction(exactly: $0)
        },
        .binary(.approximateFraction, Float80.self, Int.self) {
            try List(Approximator.guessFraction($0, accurateTo: $1))
        }
    ]
}
