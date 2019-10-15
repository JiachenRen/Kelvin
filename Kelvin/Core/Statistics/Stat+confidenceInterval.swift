//
//  Stat+confidenceInterval.swift
//  Kelvin
//
//  Created by Jiachen Ren on 3/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Condidence intervals:
/// - z interval: statistic +/- (critical value) x (standard deviation of statistic)
/// - t interval: statistic +/- (critical value of t dist.) * Sx / √n
/// - 2 sample z interval:
/// - 2 sample t interval
/// - 1 prop z interval: p̂ +/- z * √(p̂(1-p̂)/n)
/// - 2 prop z interval
public extension Stat {
    typealias CI = (lowerBound: Float80, upperBound: Float80)
    typealias TwoVarStatResult = (mean1: Float80, mean2: Float80, sx1: Float80, sx2: Float80, n1: Int, n2: Int)
    typealias OneVarStatResult = (mean: Float80, sx: Float80, n: Int)
    
    /// Computes the z score (also known as critical value) from confidence level
    static func zScore(confidenceLevel c: Float80) throws -> Float80 {
        return try abs(Float80(invNorm((1 - Double(c)) / 2)))
    }
    
    /// Computes t score from C and DF
    static func tScore<T: Number>(
        confidenceLevel c: Float80,
        degreesOfFreedom df: T
    ) throws -> Float80 {
        return try abs(invT((1 - c) / 2, df))
    }
    
    /// Calculates the z interval from statistics
    ///
    /// - Example: `zInterval(0.5,2,3,0.95)`
    ///
    /// - Parameters:
    ///     - sigma: Population standard deviation
    ///     - n: Sample size
    ///     - statistic: Mean of the sample (x̅)
    ///     - c: Confidence level (between 0 and 1)
    ///
    /// - Returns: (Confidence Interval, Margin of Error, Critical Value z)
    static func zInterval(
        sigma: Float80,
        mean: Float80,
        sampleSize n: Int,
        confidenceLevel c: Float80
    ) throws -> (ci: CI, me: Float80, z: Float80) {
        let z = try zScore(confidenceLevel: c)
        let stdev_stat = sigma / sqrt(Float80(n)) // Compute statistic stdev
        let me = z * stdev_stat // Compute margin of error
        let ci = (mean - me, mean + me)
        return (ci, me, z)
    }
    
    /// Calculates the z interval from sample data
    ///
    /// - Example: `zInterval(0.5,{1,2,3},0.95) | println($0)`
    ///
    /// - Parameters:
    ///     - sigma: Population standard deviation
    ///     - sample: A random sample from population
    ///     - c: Confidence level (between 0 and 1)
    ///
    /// - Returns: (Confidence Interval, Margin of Error, Sx, Sample Mean)
    static func zInterval(
        sigma: Float80,
        sample: [Float80],
        confidenceLevel c: Float80
    ) throws -> (ci: CI, me: Float80, oneVar: OneVarStatResult, z: Float80) {
        let r = oneVar(sample: sample)
        let (ci, me, z) = try zInterval(
            sigma: sigma,
            mean: r.mean,
            sampleSize: r.n,
            confidenceLevel: c
        )
        return (ci, me, r, z)
    }
    
    /// Calculates t interval from statistics of sample
    /// `CI = statistic +/- (critical value of t dist. (t)) * Sx / √n`,
    /// where `t = abs(invT((1 - Confidence Level) / 2, DF)`
    ///
    /// - Parameters:
    ///     - statistic: Sample mean `x̅`
    ///     - sx: Sample standard deviation
    ///     - n: The size of the sample
    ///     - c: Confidence level (between 0 and 1)
    ///
    /// - Returns: (Confidence Interval, Margin of Err., Std. Err., Degrees of Freedom, Critical Value t)
    static func tInterval(
        mean: Float80,
        sx: Float80,
        sampleSize n: Int,
        confidenceLevel c: Float80
    ) throws -> (ci: CI, me: Float80, se: Float80, df: Int, t: Float80) {
        let df = n - 1
        let t = try tScore(confidenceLevel: c, degreesOfFreedom: df)
        
        // Calculate std. err
        let se = sx / sqrt(Float80(n))
        let me = se * t
        let ci = (mean - me, mean + me)
        return (ci, me, se, df, t)
    }
    
    /// Calculates t interval from sample data
    static func tInterval(
        sample: [Float80],
        confidenceLevel c: Float80
        ) throws -> (ci: CI, me: Float80, se: Float80, df: Int, oneVar: OneVarStatResult, t: Float80) {
        let r = oneVar(sample: sample)
        let (ci, me, se, df, t) = try tInterval(
            mean: r.mean,
            sx: r.sx,
            sampleSize: r.n,
            confidenceLevel: c
        )
        return (ci, me, se, df, r, t)
    }
    
    /// Calculates one sample proportion z interval
    /// `CI = p̂ +/- z * √(p̂(1-p̂)/n)`
    static func zIntervalOneProp(
        successes x: Int,
        sampleSize n: Int,
        confidenceLevel c: Float80
    ) throws -> (ci: CI, pHat: Float80, me: Float80, se: Float80) {
        let pHat = Float80(x) / Float80(n)
        let z = try zScore(confidenceLevel: c)
        let se = sqrt(pHat * (1 - pHat) / Float80(n))
        let me = z * se
        let ci = (pHat - me, pHat + me)
        return (ci, pHat, me, se)
    }
    
    /// Calculates two sample z interval
    /// Stdev of sampling dist. of `x̅1 - x̅2 is √(σ1 ^ 2 / n1 + σ2 ^ 2 / n2)`;
    /// The rest is the same as one samp. z interval
    ///
    /// - Parameters:
    ///     - sigma1: Population standard deviation of `x1`
    ///     - sigma2: Population standard deviation of `x2`
    ///     - statistic1: Sample mean of `x1`
    ///     - n1: Sample size of `x1`
    ///     - statistic2: Sample mean of `x2`
    ///     - n2: Sample size of `x2`
    ///     - c: Confidence level
    ///
    /// - Returns: (Confidence Interval, x̅1 - x̅2, Margin of Err., Stdev of Sampling Dist. of Diff.)
    static func zIntervalTwoSamp(
        sigma1: Float80,
        sigma2: Float80,
        mean1: Float80,
        sampleSize1 n1: Int,
        mean2: Float80,
        sampleSize2 n2: Int,
        confidenceLevel c: Float80
    ) throws -> (ci: CI, meanDiff: Float80, me: Float80, sigmaDiff: Float80) {
        let sigmaDiff = sqrt(pow(sigma1, 2) / Float80(n1) + pow(sigma2, 2) / Float80(n2))
        let meanDiff = mean1 - mean2
        let z = try zScore(confidenceLevel: c)
        let me = z * sigmaDiff
        let ci = (meanDiff - me, meanDiff + me)
        return (ci, meanDiff, me, sigmaDiff)
    }
    
    /// Calculates basic two variable statistics
    static func twoVar(sample1: [Float80], sample2: [Float80]) -> TwoVarStatResult {
        let mean1 = mean(sample1)
        let mean2 = mean(sample2)
        let n1 = sample1.count
        let n2 = sample2.count
        let sx1 = stdev(.sample, sample1)
        let sx2 = stdev(.sample, sample2)
        return (mean1, mean2, sx1, sx2, n1, n2)
    }
    
    /// Calculates basic one variable statistics
    static func oneVar(sample: [Float80]) -> OneVarStatResult {
        let mean = Stat.mean(sample)
        let sx = stdev(.sample, sample)
        let n = sample.count
        return (mean, sx, n)
    }
    
    /// Calculates two sample z interval from sample data
    ///
    /// - Parameters:
    ///     - sigma1: Stdev of pop. 1
    ///     - sigma2: Stdev of pop. 2
    ///     - sample1: A sample taken from pop. 1
    ///     - sample2: A sample taken from pop. 2
    ///     - c: Confidence level
    static func zIntervalTwoSamp(
        sigma1: Float80,
        sigma2: Float80,
        sample1: [Float80],
        sample2: [Float80],
        confidenceLevel c: Float80
    ) throws -> (ci: CI, meanDiff: Float80, me: Float80, sigmaDiff: Float80, twoVar: TwoVarStatResult) {
        let r = twoVar(sample1: sample1, sample2: sample2)
        let (ci, meanDiff, me, sigmaDiff) = try zIntervalTwoSamp(
            sigma1: sigma1,
            sigma2: sigma2,
            mean1: r.mean1,
            sampleSize1: r.n1,
            mean2: r.mean2,
            sampleSize2: r.n2,
            confidenceLevel: c
        )
        return (ci, meanDiff, me, sigmaDiff, r)
    }
    
    /// Calculates two cample t interval from sample data
    static func tIntervalTwoSamp(
        sample1: [Float80],
        sample2: [Float80],
        confidenceLevel c: Float80
    ) throws -> (
        ci: CI,
        meanDiff: Float80,
        me: Float80,
        se: Float80,
        df: Float80,
        twoVar: TwoVarStatResult
    ) {
        let r = twoVar(sample1: sample1, sample2: sample2)
        let (ci, meanDiff, me, se, df) = try tIntervalTwoSamp(
            mean1: r.mean1,
            sx1: r.sx1,
            sampleSize1:
            r.n1,
            mean2: r.mean2,
            sx2: r.sx2,
            sampleSize2: r.n2,
            confidenceLevel: c
        )
        return (ci, meanDiff, me, se, df, r)
    }
    
    /// Calculates two cample t interval from sample statistics
    static func tIntervalTwoSamp(
        mean1: Float80,
        sx1: Float80,
        sampleSize1 n1: Int,
        mean2: Float80,
        sx2: Float80,
        sampleSize2 n2: Int,
        confidenceLevel c: Float80
    ) throws -> (ci: CI, meanDiff: Float80, me: Float80, se: Float80, df: Float80) {
        let df = degreesOfFreedom(s1: sx1, n1: n1, s2: sx2, n2: n2)
        let meanDiff = mean1 - mean2
        let t = try tScore(confidenceLevel: c, degreesOfFreedom: df)
        let se = sqrt(pow(sx1, 2) / Float80(n1) + pow(sx2, 2) / Float80(n2))
        let me = t * se
        let ci = (meanDiff - me, meanDiff + me)
        return (ci, meanDiff, me, se, df)
    }
    
    /// Calculates degrees of freedom for two sample t procedure
    ///
    /// - Parameters:
    ///     - s1: Stdev. of sample 1
    ///     - n1: Size of sample 1
    ///     - s2: Stdev. of sample 2
    ///     - n2: Size of sample 2
    ///
    /// - Returns: Degrees of freedom for the 2 samples
    static func degreesOfFreedom(
        s1: Float80,
        n1: Int,
        s2: Float80,
        n2: Int
    ) -> Float80 {
        let n1 = Float80(n1)
        let n2 = Float80(n2)
        let a1 = pow(s1, 2) / n1
        let a2 = pow(s2, 2) / n2
        let num = pow(a1 + a2, 2)
        let denom = 1 / (n1 - 1) * pow(a1, 2) +
            1 / (n2 - 1) * pow(a2, 2)
        return num / denom
    }
}
