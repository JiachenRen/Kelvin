//
//  Exports+probability.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

extension Exports {
    static let probability: [Operation] = Probability.exports
}

extension Probability {
    static let exports: [Operation] = [
        // Random number generation
        .noArg(.random) {
            Float80.random(in: 0..<1)
        },
        .binary(.random, Number.self, Number.self) {(lb, ub) in
            if (lb.float80 > ub.float80) {
                throw ExecutionError.invalidRange(lowerBound: lb, upperBound: ub)
            }
            return Float80.random(in: lb.float80...ub.float80)
        },
        .unary(.random, Iterable.self) {
            $0.elements.randomElement()
        },
        .binary(.randomInt, Int.self, Int.self) {(lb, ub) in
            if (lb >= ub) {
                throw ExecutionError.invalidRange(lowerBound: lb, upperBound: ub)
            }
            return Int.random(in: lb...ub)
        },
        .unary(.randomInt, Int.self) {i in
            try Assert.domain(i, 1, Int.max)
            return BigInt(BigUInt.randomInteger(withExactWidth: i))
        },
        .unary(.randomPrime, Int.self) {
            BigInt.generatePrime($0)
        },
        .unary(.randomMatrix, Int.self) {
            try Matrix(rows: $0, cols: $0) { _, _ in Float80.random(in: 0..<1) }
        },
        .binary(.randomMatrix, Int.self, Int.self) {
            try Matrix(rows: $0, cols: $1) { _, _ in Float80.random(in: 0..<1) }
        },
        .noArg(.randomBool) {
            Bool.random()
        },
        
        // Combination and permutation
        .binary(.npr, Int.self, Int.self) {
            Probability.nPr($0.float80, $1.float80)
        },
        .binary(.npr, Iterable.self, Int.self) {
            List(Probability.permutations(of: $0.elements, $1).map { List($0) })
        },
        .binary(.ncr, Int.self, Int.self) {
            Probability.nCr($0.float80, $1.float80)
        },
        .binary(.ncr, Iterable.self, Int.self) {
            List(Probability.combinations(of: $0.elements, $1).map { List($0) })
        },
        .unary(.powerset, Iterable.self) { iterable in
            List(Probability.powerset(of: iterable.elements).map { List($0) })
        },

        // Factorial
        .unary(.factorial, Int.self) {
            $0.factorial()
        }
    ]
}
