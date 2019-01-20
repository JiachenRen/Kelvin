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
    .init("=", [.any, .any]) {
        Equation(lhs: $0[0], rhs: $0[1])
    },
    .init("<", [.any, .any]) {
        Equation(lhs: $0[0], rhs: $0[1], mode: .lessThan)
    },
    .init(">", [.any, .any]) {
        Equation(lhs: $0[0], rhs: $0[1], mode: .greaterThan)
    },
    .init(">=", [.any, .any]) {
        Equation(lhs: $0[0], rhs: $0[1], mode: .greaterThanOrEquals)
    },
    .init("<=", [.any, .any]) {
        Equation(lhs: $0[0], rhs: $0[1], mode: .lessThanOrEquals)
    },
    .init("equals", [.any, .any]) {
        $0[0] === $0[1]
    },
]
