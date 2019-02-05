//
//  Equality.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

// Equality, inequality, and equations
let relationalOperations: [Operation] = [
    .binary(.equates, [.any, .any]) {
        Equation(lhs: $0, rhs: $1)
    },
    .binary(.lessThan, [.any, .any]) {
        Equation(lhs: $0, rhs: $1, mode: .lessThan)
    },
    .binary(.greaterThan, [.any, .any]) {
        Equation(lhs: $0, rhs: $1, mode: .greaterThan)
    },
    .binary(.greaterThanOrEquals, [.any, .any]) {
        Equation(lhs: $0, rhs: $1, mode: .greaterThanOrEquals)
    },
    .binary(.lessThanOrEquals, [.any, .any]) {
        Equation(lhs: $0, rhs: $1, mode: .lessThanOrEquals)
    },
    .binary(.equals, [.any, .any]) {
        $0 === $1
    },
    .binary(.notEquals, [.any, .any]) {
        $0 !== $1
    }
]
