//
//  Regression.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/25/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Linear, quadratic, cubic, etc., regression
public extension Stat {
    
    /// Calculates the least squares regression line.
    /// - Formula:
    /// Slope(m) = r(sy/sx),
    /// Intercept(b) = ȳ - mx̅
    public static func linearRegression(
        _ datasetX: [Float80],
        _ datasetY: [Float80]
    ) throws -> (slope: Float80, yIntercept: Float80) {
        
        let r = try correlation(datasetX, datasetY)
        let sy = stdev(.sample, datasetY)
        let sx = stdev(.sample, datasetX)
        let m = r * sy / sx
        
        let meanX = mean(datasetX)
        let meanY = mean(datasetY)
        let b = meanY - m * meanX
        
        return (m, b)
    }
    
    /// Residual = Observed value - Predicted value;
    /// e = y - ŷ
    public static func residuals(
        _ datasetX: [Float80],
        _ datasetY: [Float80]
    ) throws -> [Float80] {
        
        let (m, b) = try linearRegression(datasetX, datasetY)
        return zip(datasetX, datasetY).map {(x, y) in
            y - (x * m + b)
        }
    }
}
