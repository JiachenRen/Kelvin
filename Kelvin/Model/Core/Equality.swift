//
//  Equality.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

// Equality, inequality, and equations
let equalityOperations: [Operation] = [
    .binary("=", [.any, .any]) {
        Equation(lhs: $0, rhs: $1)
    },
    .binary("<", [.any, .any]) {
        Equation(lhs: $0, rhs: $1, mode: .lessThan)
    },
    .binary(">", [.any, .any]) {
        Equation(lhs: $0, rhs: $1, mode: .greaterThan)
    },
    .binary(">=", [.any, .any]) {
        Equation(lhs: $0, rhs: $1, mode: .greaterThanOrEquals)
    },
    .binary("<=", [.any, .any]) {
        Equation(lhs: $0, rhs: $1, mode: .lessThanOrEquals)
    },
    .binary("equals", [.any, .any]) {
        $0 === $1
    },
]
