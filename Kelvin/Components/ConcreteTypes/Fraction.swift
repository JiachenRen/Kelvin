//
//  Fraction.swift
//  Kelvin
//
//  Created by Jiachen Ren on 3/2/18.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

public final class Fraction: Exact {
    public var fraction: Fraction { self }
    /// Tolerance used when converting floating point to fraction.
    public static var defaultTolerance: Float80 = 5E-7
    /// Calculates the raw float80 value of the fraction. Precision may be compromised.
    public var float80: Float80 {
        let (quotient, remainder) = numerator.quotientAndRemainder(dividingBy: denominator)
        let decimal = Float80(remainder) / Float80(denominator)
        return (Float80(quotient) + decimal) * Float80(sign)
    }
    
    /// Fraction has the same precedence as division and multiplication
    public var precedence: Keyword.Precedence { .scaling }
    public var stringified: String { "\((numerator * sign).stringified)/\(denominator.stringified)" }
    public var ansiColored: String { (numerator * sign).ansiColored + "/".blue + denominator.ansiColored }
    /// Numerator of the fraction; always positive.
    public private(set) var numerator: BigInt
    /// Denominator of the fraction; always positive.
    public private(set) var denominator: BigInt
    /// Sign of the fraction, either 0, 1, or -1.
    public private(set) var sign: BigInt
    /// True if the fraction is negative.
    public var isNegative: Bool { sign == -1 }
    /// If the denominator of the fraction is 0, the fraction is infinite.
    public var isInfinite: Bool { denominator == 0 }
    /// Inverse of the fraction.
    public var inverse: Fraction { Fraction(denominator, numerator, sign: sign, isReduced: true) }
    /// A dictionary that converts float80 values to their exact fractional counterparts with denominator ≤ 1000, if it exists.
    private static let fracMap1000: [Float80: (Int, Int)] = {
        Program.shared.io?.log("initializing fraction1000, please wait...")
        var dict = [Float80: (Int, Int)]()
        for i in 1...1000 {
            for j in 2...1000 {
                let r = Float80(i) / Float80(j)
                if dict[r] == nil {
                    dict[r] = (i, j)
                }
            }
        }
        return dict
    }()
    
    /// Creates a new fraction from `denominator` and `numerator`.
    /// - Parameters:
    ///     - numerator: The numerator of the fraction.
    ///     - sign: Sign of the fraction.
    ///     - denominator: The denominator of the fraction, a big integer.
    required init(_ numerator: BigInt, _ denominator: BigInt, sign: BigInt? = nil, isReduced: Bool = false) {
        self.numerator = numerator.abs()
        self.denominator = denominator.abs()
        self.sign = sign ?? numerator.sign * denominator.sign
        if !isReduced { reduce() }
    }
    
    convenience init(_ numerator: Int, _ denominator: Int) {
        self.init(BigInt(numerator), BigInt(denominator))
    }
    
    /// Creates a new fraction from the provided floating point number.
    /// Tolerance is the max allowed difference between the float and the fraction.
    /// - Parameters:
    ///     - float: A `Float80` that would be used to construct the fraction.
    ///     - tolerance: The max difference between the provided `float` and the fraction.
    convenience init(_ val: Float80, tolerance: Float80 = Fraction.defaultTolerance) {
        let sign = val < 0 ? -1 : 1
        let val = Swift.abs(val)
        var num = 1, h2: Int = 0, denom = 0, k2 = 1
        var b = val
        repeat {
            let a = Int(b)
            var aux = num
            num = a * num + h2
            h2 = aux
            aux = denom
            denom = a * denom + k2
            k2 = aux
            b = 1.0 / (b - Float80(a))
        } while (Swift.abs(val - Float80(num) / Float80(denom)) > val * tolerance)

        self.init(num * sign, denom)
    }
    
    /// Creates a fraction with denominator ≤ 1000 that exactly matches the provided float80 value, if there is one.
    convenience init?(exactly float80: Float80) {
        let abs = Swift.abs(float80)
        guard let (n, d) = Fraction.fracMap1000[abs] else {
            return nil
        }
        let sign = float80 == 0.0 ? 0 : float80 > 0 ? 1 : -1
        self.init(BigInt(n), BigInt(d), sign: BigInt(sign))
    }
    
    /// - Returns: The greatest common divisor of numerator and denominator.
    public func gcd() -> BigInt {
        return numerator.greatestCommonDivisor(with: denominator)
    }
    
    /// Reduces the fraction, that is, divide both the numerator and the denominator by their GCD.
    private func reduce() {
        guard denominator != 0 else { return }
        let gcd = self.gcd()
        numerator /= gcd
        denominator /= gcd
    }
    
    public func simplify() throws -> Node {
        switch denominator {
        case 0:
            return Float80.nan
        case 1:
            return numerator * sign
        default:
            break
        }
        switch numerator {
        case 0:
            return 0
        default:
            break
        }
        switch Mode.shared.rounding {
        case .approximate:
            return float80
        case .exact, .auto:
            return self
        }
    }
    
    public func equals(_ node: Node) -> Bool {
        guard let n = node as? Number else { return false }
        guard let f = n as? Fraction else {
            return self.float80 == n.float80
        }
        return self.denominator == f.denominator
            && self.numerator == f.numerator
            && self.sign == f.sign
    }
    
    public func negate() -> Fraction {
        Fraction(numerator, denominator, sign: -sign)
    }
    
    public func abs() -> Fraction {
        Fraction(numerator, denominator, sign: 1)
    }
    
    // MARK: - Add
    
    public func adding(_ exact: Exact) -> Exact {
        adding(exact.fraction)
    }
    
    public func adding(_ val: Number) -> Fraction {
        if let exact = val as? Exact {
            return adding(exact)
        } else {
            return adding(val.float80)
        }
    }
    
    public func adding(_ f: Float80) -> Fraction {
        return adding(Fraction(f))
    }
    
    public func adding(_ i: Integer) -> Fraction {
        return adding(Fraction(i.bigInt, 1))
    }
    
    public func adding(_ frac: Fraction) -> Fraction {
        let gcd = denominator.greatestCommonDivisor(with: frac.denominator)
        let lcm = denominator * frac.denominator / gcd
        let a = numerator * lcm / denominator * sign
        let b = frac.numerator * lcm / frac.denominator * frac.sign
        return Fraction(a + b, lcm)
    }
    
    // MARK: - Subtract
    
    public func subtracting(_ exact: Exact) -> Exact {
        subtracting(exact.fraction)
    }
    
    public func subtracting(_ val: Number) -> Fraction {
        if let exact = val as? Exact {
            return subtracting(exact)
        } else {
            return subtracting(val.float80)
        }
    }
    
    public func subtracting(_ frac: Fraction) -> Fraction {
        return adding(frac.negate())
    }
    
    public func subtracting(_ i: Integer) -> Fraction {
        return adding(-i.bigInt)
    }
    
    public func subtracting(_ f: Float80) -> Fraction {
        return adding(Fraction(-f))
    }
    
    // MARK: - Power
    
    public func power(_ exact: Exact) -> Node? {
        power(exact.fraction)
    }
    
    public func power(_ val: Number) -> Node? {
        if let exact = val as? Exact {
            return power(exact)
        } else {
            return power(Fraction(val.float80))
        }
    }
    
    public func power(_ exponent: Fraction) -> Node? {
        guard let s = power(exponent.numerator * exponent.sign) else {
            return Float80.nan
        }
        guard exponent.denominator != 1 else {
            return s
        }
        // (n/d) ^ (1/r) => a/b * (m/t) ^ (1/r)
        let r = exponent.denominator
        let n = s.numerator, d = s.denominator
        let p1 = n.primeFactors()
        let p2 = d.primeFactors()
        var a: BigInt = 1, b: BigInt = 1, m: BigInt = 1, t: BigInt = 1
        for (i, k) in p1 {
            guard let q = Int(exactly: k / r) else {
                return Float80.nan
            }
            a *= i.power(q)
            guard let p = (k - BigInt(q) * r).int64 else {
                return Float80.nan
            }
            m *= i.power(p)
        }
        for (i, k) in p2 {
            guard let q = Int(exactly: k / r) else {
                return Float80.nan
            }
            b *= i.power(q)
            guard let p = (k - BigInt(q) * r).int64 else {
                return Float80.nan
            }
            t *= i.power(p)
        }
        if a == 1 && b == 1 {
            return nil
        }
        return Fraction(a, b, sign: 1) * (Fraction(m, t, sign: s.sign) ^ Fraction(1, r, sign: 1))
    }
    
    public func power(_ i: Integer) -> Fraction? {
        if let exact = i.int64 {
            return exact < 0 ? power(-exact)?.inverse : Fraction(numerator.power(exact), denominator.power(exact), sign: sign.power(exact))
        }
        return nil
    }
    
    // MARK: - Multiply
    
    public func multiplying(_ exact: Exact) -> Exact {
        multiplying(exact.fraction)
    }
    
    public func multiplying(_ val: Number) -> Fraction {
        if let exact = val as? Exact {
            return multiplying(exact)
        } else {
            return multiplying(val.float80)
        }
    }
    
    public func multiplying(_ frac: Fraction) -> Fraction {
        return Fraction(numerator * frac.numerator, denominator * frac.denominator, sign: sign * frac.sign)
    }
    
    public func multiplying(_ i: Integer) -> Fraction {
        return Fraction(numerator * i.bigInt, denominator, sign: sign * i.bigInt.sign)
    }
    
    public func multiplying(_ f: Float80) -> Fraction {
        return multiplying(Fraction(f))
    }
    
    // MARK: - Divide
    
    public func dividing(_ exact: Exact) -> Exact {
        dividing(exact.fraction)
    }
    
    public func dividing(_ val: Number) -> Fraction {
        if let exact = val as? Exact {
            return dividing(exact)
        } else {
            return dividing(val.float80)
        }
    }
    
    public func dividing(_ frac: Fraction) -> Fraction {
        return multiplying(frac.inverse)
    }
    
    public func dividing(_ i: Integer) -> Fraction {
        return Fraction(numerator, denominator * i.bigInt, sign: sign * i.bigInt.sign)
    }
    
    public func dividing(_ f: Float80) -> Fraction {
        return dividing(Fraction(f))
    }
}
