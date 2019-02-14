//
//  OneVar.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/28/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import GameKit

/// Distribution
/// TODO: Confidence interval, margin of error.
/// Margin of error = z-score (from confidence interval) * stdev of sampling dist.
/// Confidence interval = estimate +/- margin of error.
public extension Stat {
    
    /// Binomial cummulative distribution
    public static func binomCdf(trials: Int, prSuccess pr: Node, lowerBound lb: Int, upperBound ub: Int) throws -> Node {
        try Constraint.domain(trials, 0, Double.infinity)
        try Constraint.domain(lb, 0, trials)
        try Constraint.domain(ub, 0, trials)
        try Constraint.range(lb, ub)
        return (lb...ub).map {
            binomPdf(trials: trials, prSuccess: pr, $0)
        }.reduce(0) {
            $0 + $1
        }
    }
    
    /**
     Calculates probability for obtaining x number of successes, where x every
     an integer from 0 to number of trials.
     
     - Parameters:
        - trials: Number of trials to be carried out
        - prSuccess: A double b/w 0 and 1 that is the probability of success
     */
    public static func binomPdf(trials: Int, prSuccess pr: Node) -> [Node] {
        return (0...trials).map {
            binomPdf(trials: trials, prSuccess: pr, $0)
        }
    }
    
    /**
     Calculates binominal probability distribution
     - Parameters:
        - trials: Number of trials to be carried out
        - prSuccess: A double b/w 0 and 1 that is the probability of success
        - x: Number of successes
     - Returns: The probability of getting the specified number of successes.
     */
    public static func binomPdf(trials: Node, prSuccess pr: Node, _ x: Node) -> Node {
        return Function(.ncr, [trials, x]) * (pr ^ x) * ((1 - pr) ^ (trials - x))
    }
    
    /// A lightweight algorithm for calculating cummulative distribution frequency.
    public static func normCdf(_ x: Double) -> Double {
        var L: Double, K: Double, w: Double
        
        // Constants
        let a1 = 0.31938153, a2 = -0.356563782, a3 = 1.781477937
        let a4 = -1.821255978, a5 = 1.330274429
        
        L = fabs(x)
        K = 1.0 / (1.0 + 0.2316419 * L)
        w = 1.0 - 1.0 / sqrt(2 * .pi) * exp(-L * L / 2) * (a1 * K + a2 * K * K + a3 * pow(K, 3) + a4 * pow(K, 4) + a5 * pow(K, 5))
        
        if (x < 0 ){
            w = 1.0 - w
        }
        return w
    }
    
    /**
     Cummulative distribution frequency from lower bound to upper bound,
     where the normal curve is centered at zero with stdev of 1.
     
     - Parameters:
     - from: Lower bound
     - to: Upper bound
     - Returns: Cummulative distribution frequency from lowerbound to upperbound.
     */
    public static func normCdf(from lb: Double, to ub: Double) -> Double {
        return normCdf(ub) - normCdf(lb)
    }
    
    /**
     Cummulative distribution frequency from lower bound to upper bound,
     where the normal curve is centered at μ with stdev of σ.
     
     - Parameters:
     - from: Lower bound
     - to: Upper bound
     - μ: mean
     - σ: Standard deviation
     - Returns: Cummulative distribution frequency from lowerbound to upperbound.
     */
    public static func normCdf(from lb: Double, to ub: Double, μ: Double, σ: Double) -> Double {
        return normCdf((ub - μ) / σ) - normCdf((lb - μ) / σ)
    }
    
    /**
     Normal probability density function.
     Definition: 1 / √(2π) * e ^ (-1 / 2) ^ 2
     */
    public static func normPdf(_ x: Node) -> Node {
        return 1 / √(2 * "pi"&) * ("e"& ^ ((-1 / 2) * (x ^ 2)))
    }
    
    /**
     normalPdf(x,μ,σ)=1 / σ * normalPdf((x−μ) / σ)
     */
    public static func normPdf(_ x: Node, μ: Node, σ: Node) -> Node {
        return 1 / σ * normPdf((x - μ) / σ)
    }
    
    public static func randNorm(μ: Double, σ: Double, n: Int) -> [Double] {
        let gaussianDist = GaussianDistribution(
            randomSource: GKRandomSource(),
            mean: Float(μ),
            deviation: Float(σ))
        return [Double](repeating: 0, count: n).map {_ in
            Double(gaussianDist.nextFloat())
        }
    }
    
    private class GaussianDistribution {
        private let randomSource: GKRandomSource
        let mean: Float
        let deviation: Float
        
        init(randomSource: GKRandomSource, mean: Float, deviation: Float) {
            precondition(deviation >= 0)
            self.randomSource = randomSource
            self.mean = mean
            self.deviation = deviation
        }
        
        func nextFloat() -> Float {
            guard deviation > 0 else { return mean }
            
            let x1 = randomSource.nextUniform() // A random number between 0 and 1
            let x2 = randomSource.nextUniform() // A random number between 0 and 1
            let z1 = sqrt(-2 * log(x1)) * cos(2 * Float.pi * x2) // z1 is normally distributed
            
            // Convert z1 from the Standard Normal Distribution to our Normal Distribution
            return z1 * deviation + mean
        }
    }
    
    /**
     Convert an area representing cummulative distribution frequency to its
     corresponding standard deviation. Of course I didn't come up with this
     beast myself!
     
     - Credit: https://stackedboxes.org/2017/05/01/acklams-normal-quantile-function/
     */
    public static func invNorm(_ p: Double) throws -> Double {
        try Constraint.domain(p, 0, 1)
        
        let a1 = -39.69683028665376
        let a2 = 220.9460984245205
        let a3 = -275.9285104469687
        let a4 = 138.3577518672690
        let a5 = -30.66479806614716
        let a6 = 2.50662827745
        
        let b1 = -54.47609879822406
        let b2 = 161.5858368580409
        let b3 = -155.6989798598866
        let b4 = 66.80131188771972
        let b5 = -13.2806815528
        
        let c1 = -0.007784894002430293
        let c2 = -0.3223964580411365
        let c3 = -2.400758277161838
        let c4 = -2.549732539343734
        let c5 = 4.374664141464968
        let c6 = 2.93816398269
        
        let d1 = 0.007784695709041462
        let d2 = 0.3224671290700398
        let d3 = 2.445134137142996
        let d4 = 3.754408661907416
        
        let p_low =  0.02425
        let p_high = 1 - p_low
        var q: Double, r: Double, e: Double, u: Double
        var x = 0.0
        
        // Rational approximation for lower region.
        if (0 < p && p < p_low) {
            q = sqrt(-2 * log(p))
            x = (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) / ((((d1 * q + d2) * q + d3) * q + d4) * q + 1)
        }
        
        // Rational approximation for central region.
        if (p_low <= p && p <= p_high) {
            q = p - 0.5
            r = q * q
            x = (((((a1 * r + a2) * r + a3) * r + a4) * r + a5) * r + a6) * q / (((((b1 * r + b2) * r + b3) * r + b4) * r + b5) * r + 1)
        }
        
        // Rational approximation for upper region.
        if (p_high < p && p < 1) {
            q = sqrt(-2 * log(1 - p))
            x = -(((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) / ((((d1 * q + d2) * q + d3) * q + d4) * q + 1)
        }
        
        if 0 < p && p < 1 {
            e = 0.5 * erfc(-x / sqrt(2)) - p
            u = e * sqrt(2 * .pi) * exp(x * x / 2)
            x = x - u / (1 + x * u / 2)
        }
        
        return x
    }
}
