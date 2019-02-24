//
//  TwoVar.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Two-variable statistics
extension Stat {
    
    /// SAMPLE_COV(X, Y) = ∑(Xi - X̄)(Yj - Ȳ) / (n - 1)
    /// POPULATION_COV(X, Y) = ∑(Xi - X̄)(Yj - Ȳ) / (n)
    public static func covariance(
        _ type: DatasetType,
        _ datasetX: [Float80],
        _ datasetY: [Float80]) throws -> Float80 {
        
        if datasetX.count != datasetY.count {
            throw ExecutionError.dimensionMismatch(List(datasetX), List(datasetY))
        }
        
        let n = Float80(datasetX.count)
        let meanX = mean(datasetX)
        let meanY = mean(datasetY)
        
        let q: Float80 = zip(datasetX, datasetY).reduce(0) {
            $0 + ($1.0 - meanX) * ($1.1 - meanY)
        }
        
        switch type {
        case .sample:
            return q / (n - 1)
        case .population:
            return q / n
        }
    }
    
    /// Correlation is the standardized form of covariance. It is computed
    /// by the following formula:
    /// R(X, Y) = SAMPLE_COV(X, Y) / (Sx * Sy)
    /// - returns: Correlation, a value between -1 and 1
    public static func correlation(
        _ datasetX: [Float80],
        _ datasetY: [Float80]) throws -> Float80 {
        
        return try covariance(.sample, datasetX, datasetY) /
            stdev(.sample, datasetX) /
            stdev(.sample, datasetY)
    }
    
    /// Correlation squared (coefficient of determination)
    public static func determination(
        _ datasetX: [Float80],
        _ datasetY: [Float80]) throws -> Float80 {
        return try pow(correlation(datasetX, datasetY), 2.0)
    }
    
    /// ∑xy
    public static func sumXY(
        _ datasetX: [Float80],
        _ datasetY: [Float80]) throws -> Float80 {
        
        if datasetX.count != datasetY.count {
            throw ExecutionError.dimensionMismatch(List(datasetX), List(datasetY))
        }
        
        return zip(datasetX, datasetY).reduce(0) {
            $0 + $1.0 * $1.1
        }
    }
}
