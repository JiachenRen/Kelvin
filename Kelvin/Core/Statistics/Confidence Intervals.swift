//
//  ConfidenceInterval.swift
//  macOS Application
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
    public typealias CI = (lowerBound: Float80, upperBound: Float80)
    
    /// Calculates the z interval from statistics
    ///
    /// - Example: `zInterval(0.5,2,3,0.95)`
    ///
    /// - Parameters:
    ///     - sigma: Population standard deviation
    ///     - n: Sample size
    ///     - statistic: Mean of the sample (x̅)
    ///     - cl: Confidence level (between 0 and 1)
    ///
    /// - Returns: (Confidence Interval, Margin of Error, Critical Value z)
    public static func zInterval(
        sigma: Float80,
        statistic: Float80,
        sampleSize n: Int,
        confidenceLevel cl: Float80
    ) throws -> (ci: CI, me: Float80, z: Float80) {
        let z = try abs(Float80(invNorm((1 - Double(cl)) / 2))) // Compute the critical value
        let stdev_stat = sigma / sqrt(Float80(n)) // Compute statistic stdev
        let me = z * stdev_stat // Compute margin of error
        let ci = (statistic - me, statistic + me)
        return (ci, me, z)
    }
    
    /// Calculates the z interval from sample data
    ///
    /// - Example: `zInterval(0.5,{1,2,3},0.95) | println($0)`
    ///
    /// - Parameters:
    ///     - sigma: Population standard deviation
    ///     - sample: A random sample from population
    ///     - cl: Confidence level (between 0 and 1)
    ///
    /// - Returns: (Confidence Interval, Margin of Error, Sx, Sample Mean)
    public static func zInterval(
        sigma: Float80,
        sample: [Float80],
        confidenceLevel cl: Float80
        ) throws -> (ci: CI, me: Float80, sx: Float80, statistic: Float80, n: Int, z: Float80) {
        let statistic = mean(sample)
        let n = sample.count
        let (ci, me, z) = try zInterval(
            sigma: sigma,
            statistic: statistic,
            sampleSize: n,
            confidenceLevel: cl
        )
        let sx = stdev(.sample, sample)
        return (ci, me, sx, statistic, n, z)
    }
    
    /// Calculates t interval from statistics of sample
    /// CI = statistic +/- (critical value of t dist. (t)) * Sx / √n,
    /// where t = abs(invT((1 - Confidence Level) / 2, DF)
    ///
    /// - Parameters:
    ///     - statistic: Sample mean (x̅)
    ///     - sx: Sample standard deviation
    ///     - n: The size of the sample
    ///     - cl: Confidence level (between 0 and 1)
    ///
    /// - Returns: (Confidence Interval, Margin of Err., Std. Err., Degrees of Freedom, Critical Value t)
    public static func tInterval(
        statistic: Float80,
        sx: Float80,
        sampleSize n: Int,
        confidenceLevel cl: Float80
        ) throws -> (ci: CI, me: Float80, se: Float80, df: Int, t: Float80) {
        let df = n - 1
        let t = try abs(invT((1 - cl) / 2, df))
        
        // Calculate std. err
        let se = sx / sqrt(Float80(n))
        let me = se * t
        let ci = (statistic - me, statistic + me)
        return (ci, me, se, df, t)
    }
    
    /// Calculates t interval from sample data
    public static func tInterval(
        sample: [Float80],
        confidenceLevel cl: Float80
        ) throws -> (ci: CI, statistic: Float80, me: Float80, se: Float80, df: Int, sx: Float80, n: Int, t: Float80) {
        let statistic = mean(sample)
        let sx = stdev(.sample, sample)
        let n = sample.count
        let (ci, me, se, df, t) = try tInterval(
            statistic: statistic,
            sx: sx,
            sampleSize: n,
            confidenceLevel: cl
        )
        return (ci, statistic, me, se, df, sx, n, t)
    }
    
    /// Calculates one sample proportion z interval
    /// CI = p̂ +/- z * √(p̂(1-p̂)/n)
    public static func zIntervalOneProp(
        successes x: Int,
        sampleSize n: Int,
        confidenceLevel cl: Float80
    ) throws -> (ci: CI, statistic: Float80, me: Float80, se: Float80) {
        let statistic = Float80(x) / Float80(n)
        let z = try abs(Float80(invNorm(Double((1 - cl) / 2))))
        let se = sqrt(statistic * (1 - statistic) / Float80(n))
        let me = z * se
        let ci = (statistic - me, statistic + me)
        return (ci, statistic, me, se)
    }
    
}
