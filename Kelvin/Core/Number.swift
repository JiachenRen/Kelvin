//
//  Number.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let numberOperations: [Operation] = [
    .binary(.greatestCommonDivisor, Int.self, Int.self) {
        gcd($0, $1)
    },
    .binary(.leastCommonMultiple, Int.self, Int.self) {
        lcm($0, $1)
    },
    .unary(.factorize, Int.self) {
        List(primeFactors(of: $0))
    },
    .unary(.degrees, [.any]) {
        $0 / 180 * ("pi"&)
    },
    .unary(.percent, [.any]) {
        $0 / 100
    },
    .binary(.round, Value.self, Int.self) {
        round($0.float80, toDecimalPlaces: $1)
    }
]

public func gcd(_ a: Int, _ b: Int) -> Int {
    let a = abs(a)
    let b = abs(b)
    if a == 0 || b == 0 {
        return a == 0 ? b : a
    } else if a > b {
        return gcd(b, a % b)
    }
    return gcd(a, b % a)
}

public func lcm(_ a: Int, _ b: Int) -> Int {
    let g = gcd(a, b)
    return g == 0 ? 0 : abs(a * b / g)
}

public func primeFactors(of n: Int) -> [Int] {
    var n = n
    var factors = [Int]()
    
    if n == 0 || n == 1 {
        factors.append(n)
        return factors
    } else if n < 0 {
        factors.append(-1)
        n /= -1
    }
    
    // Find the number of 2s that divide n
    while n % 2 == 0 {
        factors.append(2)
        n /= 2
    }
    
    // n must be odd at this point.
    var i = 3
    while i <= Int(sqrt(Double(n))) {
        
        // While i divides n, add i and divide n
        while (n % i == 0) {
            factors.append(i)
            n /= i;
        }
        
        i += 2
    }
    
    
    // This condition is to handle the case whien
    // n is a prime number greater than 2
    if (n > 2) {
        factors.append(n)
    }
    
    return factors
}

/// Rounds `x` to specified `dp` decimal places.
public func round(_ x: Float80, toDecimalPlaces dp: Int) -> Float80 {
    let p = pow(Float80(10.0), Float80(dp))
    return round(x * p) / p
}
