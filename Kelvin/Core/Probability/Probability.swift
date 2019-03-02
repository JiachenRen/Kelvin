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
        Float80.random(in: 0...1)
    },
    .binary(.random, Value.self, Value.self) {(lb, ub) in
        let i = min(lb.float80, ub.float80)
        let j = max(lb.float80, ub.float80)
        return Float80.random(in: i...j)
    },
    .unary(.random, List.self) {
        $0.elements.randomElement()
    },

    // Combination and permutation
    .binary(.npr, Int.self, Int.self) {
        nPr($0.float80, $1.float80)
    },
    .binary(.ncr, Int.self, Int.self) {
        nCr($0.float80, $1.float80)
    },
    .binary(.ncr, List.self, Int.self) {
        List(combinations(of: $0.elements, $1).map {List($0)})
    },

    // Factorial
    .unary(.factorial, Int.self) {
        factorial($0.float80)
    },
]

/// Combination
/// - Returns: Number of possible permutations when selecting r ordered elements from a pool of n elements.
public func nCr(_ n: Float80, _ r: Float80) -> Float80 {
    return nPr(n, r) / factorial(r)
}

/// Permutation
/// - Returns: Number of possible permutations when selecting r ordered elements from a pool of n elements.
public func nPr(_ n: Float80, _ r: Float80) -> Float80 {
    return n < (n - r) ? .nan : n == (n - r) ? 1 : n * nPr(n - 1, r - 1)
}

/// A very concise definition of factorial.
public func factorial(_ n: Float80) -> Float80 {
    return n < 0 ? .nan : n == 0 ? 1 : n * factorial(n - 1)
}

/**
 The number of different, unordered combinations of r
 objects from a set of n objects. Definition: nCr(n,r)=nPr(n,r)/r!=n!/r!(n−r)!
 */
public func combinations<T>(of arr: [T], _ r: Int) -> [[T]] {
    func combinationUtil<T>(
        _ arr: [T],
        _ data: inout [T?],
        _ start: Int,
        _ end: Int,
        _ index: Int,
        _ r: Int) -> [[T]] {
        
        // Current combination is ready, unwrap and return.
        if (index == r) {
            return [data.compactMap {$0}]
        }
        
        // Replace index with all possible elements. The condition
        // "end-i+1 >= r-index" makes sure that including one element
        // at index will make a combination with remaining elements
        // at remaining positions
        var combinations = [[T]]()
        for i in start...end {
            if !(i <= end && end - i + 1 >= r - index) {
                return combinations
            }
            data[index] = arr[i];
            let comb = combinationUtil(arr, &data, i + 1, end, index + 1, r)
            combinations.append(contentsOf: comb)
        }
        return combinations
    }
    
    var data = [T?](repeating: nil, count: r)
    return combinationUtil(arr, &data, 0, arr.count - 1, 0, r)
}
