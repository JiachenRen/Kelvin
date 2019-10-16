//
//  BigInt+Number.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/11/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

extension BigInt: Integer {
    public var float80: Float80 {
        if let exact = Float80(exactly: self) {
            return exact
        }
        Program.shared.io?.warning("precision maybe compromised - big integer -> float80")
        return Float80(self)
    }
    public var sign: BigInt { self == 0 ? 0 : self > 0 ? 1 : -1 }
    public var ansiColored: String { description.bold.blue }
    public var int64: Int? { Int(exactly: self) }
    public var bigInt: BigInt { self }
    public func simplify() -> Node { Int(exactly: self) ?? self }
    public func negate() -> BigInt { -self }
    public func abs() -> BigInt { self > 0 ? self : -self }
    
    /// - Returns: The least common multiple with i.
    public func leastCommonMultiple(with i: BigInt) -> BigInt {
        self * i / greatestCommonDivisor(with: i)
    }
    
    /// - Returns: The prime factors of this integer expressed in tuples `(factor, multiplicity)`
    public func primeFactors() -> [(factor: BigInt, multiplicity: BigInt)] {
        var n = self
        var factors: [(BigInt, BigInt)] = []
        var divisor: BigInt = 2
        while divisor * divisor <= n {
            var power: BigInt = 0
            while n % divisor == 0 {
                power += 1
                n /= divisor
            }
            if power != 0 {
                factors.append((divisor, power))
            }
            divisor += divisor == 2 ? 1 : 2
        }
        if n > 1 {
            factors.append((n, 1))
        }

        return factors
    }
    
    /// Generates a prime of the specified bit width.
    public static func generatePrime(_ width: Int) -> BigInt {
        while true {
            var random = BigUInt.randomInteger(withExactWidth: width)
            random |= BigUInt(1)
            if random.isPrime() {
                return BigInt(random)
            }
        }
    }
}
