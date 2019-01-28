//
//  Probability.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let probabilityOperations: [Operation] = [

    // Random number generation
    .init(.random, []) { _ in
        return Double.random(in: 0...1)
    },
    .binary(.random, [.number, .number]) {
        let lb = $0≈!
        let ub = $1≈!
        let i = min(lb, ub)
        let j = max(lb, ub)
        return Double.random(in: i...j)
    },

    // Combination and permutation
    .binary(.npr, [.any, .any]) {
        return $0~! / ($0 - $1)~!
    },
    .binary(.ncr, [.any, .any]) {
        return Function(.npr, [$0, $1]) / $1~!
    },

    // Factorial
    .unary(.factorial, [.number]) {
        if let i = Int(exactly: $0≈!) {
            return factorial(Double(i))
        }
        throw ExecutionError.general(errMsg: "can only perform factorial on an integer")
    },
]

/// A very concise definition of factorial.
fileprivate func factorial(_ n: Double) -> Double {
    return n < 0 ? .nan : n == 0 ? 1 : n * factorial(n - 1)
}
