//
//  Stat+twoVar.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Two-variable statistics
public extension Stat {
    enum DatasetType {
        case sample
        case population
    }
    
    /// `SAMPLE_COV(X, Y) = ∑(Xi - X̄)(Yj - Ȳ) / (n - 1)`
    /// `POPULATION_COV(X, Y) = ∑(Xi - X̄)(Yj - Ȳ) / (n)`
    static func covariance(
        _ type: DatasetType,
        _ datasetX: [Float80],
        _ datasetY: [Float80]
    ) throws -> Float80 {
        
        if datasetX.count != datasetY.count {
            throw ExecutionError.dimensionMismatch(Vector(datasetX), Vector(datasetY))
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
    /// `R(X, Y) = SAMPLE_COV(X, Y) / (Sx * Sy)`
    /// - returns: Correlation, a value between -1 and 1
    static func correlation(
        _ datasetX: [Float80],
        _ datasetY: [Float80]
    ) throws -> Float80 {
        
        return try covariance(.sample, datasetX, datasetY) /
            stdev(.sample, datasetX) /
            stdev(.sample, datasetY)
    }
    
    /// Calculates coefficient of determination, `R²`.
    /// For calculation of `R²`, the general definition is used:
    /// `R² = 1 - ssRes / ssTot`.
    /// Refer to https://en.wikipedia.org/wiki/Coefficient_of_determination
    static func determination(
        _ datasetY: [Float80],
        _ resid: [Float80]
    ) throws -> Float80 {
        
        let meanY = mean(datasetY)
        
        // Total sum of squares
        let ssTot: Float80 = datasetY.reduce(0) {
            $0 + pow($1 - meanY, 2.0)
        }
        
        // Sum of squares of residuals
        let ssRes: Float80 = resid.reduce(0) {
            $0 + pow($1, 2.0)
        }
        
        // R² = 1 - ssRes / ssTot
        return 1.0 - ssRes / ssTot
    }
    
    /// `∑xy`
    static func sumXY(
        _ datasetX: [Float80],
        _ datasetY: [Float80]
    ) throws -> Float80 {
        
        if datasetX.count != datasetY.count {
            throw ExecutionError.dimensionMismatch(Vector(datasetX), Vector(datasetY))
        }
        
        return zip(datasetX, datasetY).reduce(0) {
            $0 + $1.0 * $1.1
        }
    }
}
