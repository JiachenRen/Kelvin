//
//  Stat.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/28/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// A collection of stat functions and operations.
public class Stat {
    
    public enum DatasetType {
        case sample
        case population
    }
    
    public static let operations: [Operation] = [
        
        // Mark: Distribution
        
        // tPdf, tCdf, and invt
        .binary(.invT, [.number, .int]) {
            try invT($0≈!, $1 as! Int)
        },
        .binary(.tPdf, [.number, .int]) {
            try tPdf($0≈!, $1 as! Int)
        },
        .binary(.tCdf, [.number, .int]) {
            try tCdf($0≈!, $1 as! Int)
        },
        .init(.tCdf, [.number, .number, .int]) {
            try tCdf(
                lowerBound: $0[0]≈!,
                upperBound: $0[1]≈!,
                $0[2] as! Int
            )
        },
        
        // Geometric Pdf/Cdf
        .binary(.geomPdf, [.any, .int]) {
            try geomPdf(prSuccess: $0, $1 as! Int)
        },
        .init(.geomCdf, [.any, .int, .int]) {
            try geomCdf(
                prSuccess: $0[0],
                lowerBound: $0[1] as! Int,
                upperBound: $0[2] as! Int
            )
        },
        
        // Binomial Pdf/Cdf
        .init(.binomPdf, [.any, .any, .any]) {
            binomPdf(trials: $0[0], prSuccess: $0[1], $0[2])
        },
        
        .binary(.binomPdf, [.int, .any]) {
            List(binomPdf(trials: $0 as! Int, prSuccess: $1))
        },
        
        .init(.binomCdf, [.int, .any, .int, .int]) {
            try binomCdf(
                trials: $0[0] as! Int,
                prSuccess: $0[1],
                lowerBound: $0[2] as! Int,
                upperBound: $0[3] as! Int
            )
        },
        
        // normCdf from -∞ to x
        .unary(.normCdf, [.number]) {
            Float80(normCdf(Double($0≈!)))
        },
        
        // normCdf from a to b, centered at zero with stdev of 1
        .binary(.normCdf, [.number, .number]) {
            Float80(normCdf(from: Double($0≈!), to: Double($1≈!)))
        },
        // normCdf from a to b, centered at zero with stdev of 1
        .init(.normCdf, [.number, .number, .number, .number]) {
            let args: [Double] = $0.map {Double($0≈!)}
            return Float80(normCdf(from: args[0], to: args[1], μ: args[2], σ: args[3]))
        },
        .init(.randNorm, [.number, .number, .int]) {
            let elements = randNorm(μ: $0[0]≈!, σ: $0[1]≈!, n: $0[2] as! Int)
            return List(elements)
        },
        .init(.invNorm, [.number, .number, .number]) {
            let stdev = $0[2]≈!
            let mean = $0[1]≈!
            return try Float80(invNorm(Double($0[0]≈!))) * stdev + mean
        },
        .unary(.normPdf, [.any]) {
            normPdf($0)
        },
        .init(.normPdf, [.any, .any, .any]) {
            normPdf($0[0], μ: $0[1], σ: $0[2])
        },
        
        // Mark: One-variable statistics
        
        .unary(.mean, [.list]) {
            Function(.sum, [$0]) / ($0 as! List).count
        },
        .unary(.max, [.list]) {
            Function(.max, ($0 as! List).elements)
        },
        .init(.max, [.numbers]) {
            max($0.map {$0≈!})
        },
        .unary(.min, [.list]) {
            Function(.min, ($0 as! List).elements)
        },
        .init(.min, [.numbers]) {
            min($0.map {$0≈!})
        },
        .init(.mean, [.universal]) { nodes in
            ++nodes / nodes.count
        },
        .unary(.sumOfDiffSq, [.list]) {
            try ssx(($0 as! List).toNumerics())
        },
        .unary(.variance, [.list]) {
            let list = try ($0 as! List).toNumerics()
            return List([
                Pair("sample", variance(.sample, list)),
                Pair("population", variance(.population, list))
            ])
        },
        .unary(.stdev, [.list]) {
            let list = try ($0 as! List).toNumerics()

            let es = [
                Pair("Sₓ", stdev(.sample, list)),
                Pair("σₓ", stdev(.population, list))
            ]
            return List(es)
        },
        
        // Summation
        .unary(.sum, [.list]) {
            sum(($0 as! List).elements)
        },
        .init(.sum, [.universal]) { nodes in
            ++nodes
        },
        
        // IQR, 5 number summary
        .unary(.fiveNumberSummary, [.list]) {
            let list = try ($0 as! List).toNumerics()
            let sum5n = try fiveNSummary(list)
            let stats: [Pair] = [
                .init("min", sum5n[0]),
                .init("q1", sum5n[1]),
                .init("median", sum5n[2]),
                .init("q3", sum5n[3]),
                .init("max", sum5n[4])
            ]
            return List(stats)
        },
        .unary(.interQuartileRange, [.list]) {
            let list = try ($0 as! List).toNumerics()
            let stat = try quartiles(list)
            return stat.q3 - stat.q1
        },
        .unary(.median, [.list]) {
            let list = try ($0 as! List).toNumerics()
            let (m, _) = median(list)
            return m
        },
        .unary(.outliers, [.list]) {
            let list = try ($0 as! List).toNumerics()
            let outliers = try Stat.outliers(list)
            return List([
                Pair("lower end", List(outliers.lowerEnd)),
                Pair("upper end", List(outliers.upperEnd))
            ])
        },
        .unary(.oneVar, [.list]) {
            let list = try ($0 as! List).toNumerics()
            let mean = Stat.mean(list)
            let sum = Stat.sum(list)
            let sumSq = sumSquared(list)
            let s_stdev = stdev(.sample, list)
            let p_stdev = stdev(.population, list)
            let n = list.count
            let sum5n = try fiveNSummary(list)
            let ssx = Stat.ssx(list)
            
            let stats: [Pair] = [
                .init("x̅", mean),
                .init("∑x", sum),
                .init("∑x²", sumSq),
                .init("Sₓ", s_stdev),
                .init("σₓ", p_stdev),
                .init("n", n),
                .init("Minₓ", sum5n[0]),
                .init("Q₁", sum5n[1]),
                .init("Medianₓ", sum5n[2]),
                .init("Q₃", sum5n[3]),
                .init("Maxₓ", sum5n[4]),
                .init("SSX", ssx),
            ]
            
            return List(stats)
        },
        
        // Mark: Two-variable statistics
        
        .binary(.covariance, [.list, .list]) {
            let datasetX = try ($0 as! List).toNumerics()
            let datasetY = try ($1 as! List).toNumerics()
            
            return try List([
                Pair("sample", covariance(.sample, datasetX, datasetY)),
                Pair("population", covariance(.population, datasetX, datasetY))
            ])
        },
        .binary(.correlation, [.list, .list]) {
            let datasetX = try ($0 as! List).toNumerics()
            let datasetY = try ($1 as! List).toNumerics()
            
            return try correlation(datasetX, datasetY)
        },
        .binary(.determination, [.list, .list]) {
            let datasetX = try ($0 as! List).toNumerics()
            let datasetY = try ($1 as! List).toNumerics()
            
            return try determination(datasetX, datasetY)
        },
        .binary(.twoVar, [.list, .list]) {
            let datasetX = try ($0 as! List).toNumerics()
            let datasetY = try ($1 as! List).toNumerics()
            
            let meanX = mean(datasetX)
            let sumX = sum(datasetX)
            let sumSqX = sumSquared(datasetX)
            let sStdevX = stdev(.sample, datasetX)
            let pStdevX = stdev(.population, datasetX)
            let ssx = Stat.ssx(datasetX)
            let sum5nX = try fiveNSummary(datasetX)
            
            let meanY = mean(datasetY)
            let sumY = sum(datasetY)
            let sumSqY = sumSquared(datasetY)
            let sStdevY = stdev(.sample, datasetY)
            let pStdevY = stdev(.population, datasetY)
            let ssy = Stat.ssx(datasetY)
            let sum5nY = try fiveNSummary(datasetY)
            
            let n = datasetX.count
            let sumXY = try Stat.sumXY(datasetX, datasetY)
            let sCov = try covariance(.sample, datasetX, datasetY)
            let pCov = try covariance(.population, datasetX, datasetY)
            let cor = try correlation(datasetX, datasetY)
            let cod = try determination(datasetX, datasetY)
            
            let stats: [Pair] = [
                .init("x̅", meanX),
                .init("∑x", sumX),
                .init("∑x²", sumSqX),
                .init("Sx", sStdevX),
                .init("σx", pStdevX),
                .init("MinX", sum5nX[0]),
                .init("Q₁X", sum5nX[1]),
                .init("MedianX", sum5nX[2]),
                .init("Q₃X", sum5nX[3]),
                .init("MaxX", sum5nX[4]),
                .init("SSX", ssx),
                
                .init("ȳ", meanY),
                .init("∑y", sumY),
                .init("∑y²", sumSqY),
                .init("Sy", sStdevY),
                .init("σy", pStdevY),
                .init("MinY", sum5nY[0]),
                .init("Q₁Y", sum5nY[1]),
                .init("MedianY", sum5nY[2]),
                .init("Q₃Y", sum5nY[3]),
                .init("MaxY", sum5nY[4]),
                .init("SSY", ssy),
                
                .init("n", n),
                .init("∑xy", sumXY),
                .init("R", cor),
                .init("R²", cod),
                .init("Sample COV", sCov),
                .init("Population COV", pCov)
            ]
            
            return List(stats)
        },
        
        // Mark: Regression
        
        .binary(.linReg, [.list, .list]) {
            let X = try ($0 as! List).toNumerics()
            let Y = try ($1 as! List).toNumerics()
            let (slope, yInt) = try linearRegression(X, Y)
            
            let eq = Equation(
                lhs: "y"&,
                rhs: slope * "x"& + yInt
            ).finalize()
            let cor = try correlation(X, Y)
            let cod = try determination(X, Y)
            let resid = try residuals(X, Y)
            
            return List([
                Pair("RegEqn", eq),
                Pair("slope(m)", slope),
                Pair("y-int(b)", yInt),
                Pair("r²", cod),
                Pair("r", cor),
                Pair("Resid", List(resid))
            ])
        },
        .init(.linReg, [.list, .list, .var]) {
            guard let result = try Function(.linReg, [$0[0], $0[1]]).simplify() as? List else {
                throw ExecutionError.unexpected(nil)
            }
            
            guard let regEqn = (result[0] as? Pair)?.rhs as? Equation else {
                throw ExecutionError.unexpected(nil)
            }
            
            try Function(($0[2] as! Variable).name, ["x"&])
                .implement(using: regEqn.rhs)
            
            return result
        },
        .init(.polyReg, [.int, .list, .list]) {
            let l1 = try ($0[1] as! List).toNumerics()
            let l2 = try ($0[2] as! List).toNumerics()
            let k = $0[0] as! Int
            let (eq, coefs, cod, resid) = try polynomialRegression(degrees: k, l1, l2)
            
            return List([
                Pair("RegEqn", eq),
                Pair("Coef(s)", List(coefs)),
                Pair("R²", cod),
                Pair("Resid", List(resid)),
            ])
        }
    ]
}
