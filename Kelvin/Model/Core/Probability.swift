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
        Double.random(in: 0...1)
    },
    .binary(.random, [.number, .number]) {
        let lb = $0≈!
        let ub = $1≈!
        let i = min(lb, ub)
        let j = max(lb, ub)
        return Double.random(in: i...j)
    },
    .unary(.random, [.list]) {
        ($0 as! List).elements.randomElement()
    },

    // Combination and permutation
    .binary(.npr, [.any, .any]) {
        $0~! / ($0 - $1)~!
    },
    .binary(.ncr, [.any, .any]) {
        Function(.npr, [$0, $1]) / $1~!
    },
    .binary(.ncr, [.list, .int]) {
        List(combinations(of: ($0 as! List).elements, $1 as! Int).map {List($0)})
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
public func factorial(_ n: Double) -> Double {
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
