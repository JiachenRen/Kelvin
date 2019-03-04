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
/// - t interval
/// - 2 sample z interval
/// - 2 sample t interval
/// - 1 prop z interval
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
    ///     - statistic: Mean of the statistic (x̅)
    ///     - cl: Confidence level (between 0 and 1)
    ///
    /// - Returns: (Confidence Interval, Margin of Error)
    public static func zInterval(
        sigma: Float80,
        statistic: Float80,
        sampleSize n: Int,
        confidenceLevel cl: Float80
    ) throws -> (ci: CI, me: Float80) {
        let z = try abs(Float80(invNorm((1 - Double(cl)) / 2))) // Compute the critical value
        let stdev_stat = sigma / sqrt(Float80(n)) // Compute statistic stdev
        let me = z * stdev_stat // Compute margin of error
        let ci = (statistic - me, statistic + me)
        return (ci, me)
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
    /// - Returns: (Confidence Interval, Margin of Error, Sx)
    public static func zInterval(
        sigma: Float80,
        sample: [Float80],
        confidenceLevel cl: Float80
    ) throws -> (ci: CI, me: Float80, sx: Float80, statistic: Float80, n: Int) {
        let statistic = mean(sample)
        let n = sample.count
        let (ci, me) = try zInterval(
            sigma: sigma,
            statistic: statistic,
            sampleSize: n,
            confidenceLevel: cl
        )
        let sx = stdev(.sample, sample)
        return (ci, me, sx, statistic, n)
    }
}
