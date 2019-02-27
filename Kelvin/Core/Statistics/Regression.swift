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
    ) throws -> (eqn: Equation, slope: Float80, yIntercept: Float80, r: Float80, cod: Float80, resid: [Float80]) {
        
        let r = try correlation(datasetX, datasetY)
        let sy = stdev(.sample, datasetY)
        let sx = stdev(.sample, datasetX)
        let m = r * sy / sx
        
        // Calcuate y intercept
        let meanX = mean(datasetX)
        let meanY = mean(datasetY)
        let b = meanY - m * meanX
        
        // Residual = Observed value - Predicted value
        // e = y - ŷ
        let resid = zip(datasetX, datasetY).map {(x, y) in
            y - (x * m + b)
        }
        
        // Regression equation y = mx + b
        let eqn = Equation(
            lhs: "y"&,
            rhs: m * "x"& + b
        )
        
        // Another definition of cod is correlation squared
        let cod = pow(r, 2.0)
        
        return (eqn, m, b, r, cod, resid)
    }
    
    /// Polynomial least squares regression based on
    /// Gaussian elimination and Cramer's Rule.
    /// The original article that describes the procedure
    /// can be found here:
    /// https://neutrium.net/mathematics/least-squares-fitting-of-a-polynomial/
    ///
    /// **Example**
    ///
    /// `polyReg(2,{1,3,7,8,11},{2,4,20,67,100})`
    /// - Parameters:
    ///     - degrees: The highest degree of the resulting polynomial regression eqn.
    ///     - datasetX: X coordinates of the points to be fitted.
    ///     - datasetY: Y coordinates of the points to be fitted.
    /// - Returns: A tuple with the first element being the regression eqn and
    ///            the second element being an array of coefficients.
    public static func polynomialRegression(
        degrees: Int,
        _ datasetX: [Float80],
        _ datasetY: [Float80]
    ) throws -> (eqn: Equation, coefs: [Float80], cod: Float80, resid: [Float80]) {
        
        guard datasetX.count == datasetY.count else {
            throw ExecutionError.dimensionMismatch(List(datasetX), List(datasetY))
        }
        
        let sum_x_exp: [Float80] = (0...degrees * 2).map {k in
            datasetX.reduce(0) {
                $0 + pow($1, Float80(k))
            }
        }
        
        let b: [Float80] = (0...degrees).map {k in
            var sum: Float80 = 0
            for (i, x) in datasetX.enumerated() {
                sum += pow(x, Float80(k)) * datasetY[i]
            }
            return sum
        }
        
        let dim = degrees + 1
        var mat = [[Float80]](
            repeating: [Float80](repeating: 0, count: dim),
            count: dim
        )
        
        for (r, row) in mat.enumerated() {
            for (c, _) in row.enumerated() {
                mat[r][c] = sum_x_exp[r + c]
            }
        }
        
        let M = try Matrix(mat)
        let detM = try M.determinant().simplify()≈!
        
        var coefs = [Float80](repeating: 0, count: dim)
        
        // Solve the matrix using Cramer's rule
        for i in 0..<dim {
            let Mi = try M.setColumn(i, Vector(b))
            let detMi = try Mi.determinant().simplify()≈!
            coefs[i] = detMi / detM
        }
        
        // Generate definition template for f(x)
        Scope.withholdAccess(to: ["x"&])
        let rhs = try coefs.enumerated()
            .map {(i, a) in
                a * ("x"& ^ i)
            }.reduce(0) {
                $0 + $1
            }.simplify()
        Scope.releaseRestrictions()
        
        // Regression eqn
        let eqn = Equation(lhs: "y"&, rhs: rhs)
        
        // Calculate y-hat (estimated y)
        Scope.save()
        let estimatedY = try datasetX.map {x -> Float80 in
            Variable.define("x", x)
            return try eqn.rhs.simplify()≈!
        }
        Scope.restore()
        
        // Residuals
        let resid: [Float80] = zip(datasetY, estimatedY)
            .map {(yi, fi) in
                yi - fi
        }
        
        let cod = try determination(datasetY, resid)
        
        return (eqn, coefs, cod, resid)
    }
}
