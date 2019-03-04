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
        .binary(.invT, Value.self, Int.self) {
            try invT($0.float80, $1)
        },
        .binary(.tPdf, Value.self, Int.self) {
            try tPdf($0.float80, $1)
        },
        .binary(.tCdf, Value.self, Int.self) {
            try tCdf($0.float80, $1)
        },
        .ternary(.tCdf, Value.self, Value.self, Int.self) {
            try tCdf(lowerBound: $0.float80, upperBound: $1.float80, $2)
        },
        
        // Geometric Pdf/Cdf
        .binary(.geomPdf, Node.self, Int.self) {
            try geomPdf(prSuccess: $0, $1)
        },
        .ternary(.geomCdf, Node.self, Int.self, Int.self) {
            try geomCdf(prSuccess: $0, lowerBound: $1, upperBound: $2)
        },
        
        // Binomial Pdf/Cdf
        .ternary(.binomPdf, [.any, .any, .any]) {
            binomPdf(trials: $0, prSuccess: $1, $2)
        },
        .binary(.binomPdf, Int.self, Node.self) {
            List(binomPdf(trials: $0, prSuccess: $1))
        },
        .quaternary(.binomCdf, Int.self, Node.self, Int.self, Int.self) {
            try binomCdf(trials: $0, prSuccess: $1, lowerBound: $2, upperBound: $3)
        },
        
        // normCdf from -∞ to x
        .unary(.normCdf, Value.self) {
            Float80(normCdf(Double($0.float80)))
        },
        
        // normCdf from a to b, centered at zero with stdev of 1
        .binary(.normCdf, Value.self, Value.self) {
            Float80(normCdf(from: Double($0≈!), to: Double($1≈!)))
        },
        
        // normCdf from a to b, centered at zero with stdev of 1
        .init(.normCdf, [.number, .number, .number, .number]) {
            let args: [Double] = $0.map {Double($0≈!)}
            return Float80(normCdf(from: args[0], to: args[1], μ: args[2], σ: args[3]))
        },
        .ternary(.randNorm, Value.self, Value.self, Int.self) {
            let elements = randNorm(μ: $0.float80, σ: $1.float80, n: $2)
            return List(elements)
        },
        .ternary(.invNorm, Value.self, Value.self, Value.self) {
            let stdev = $2
            let mean = $1
            return try Float80(invNorm(Double($0.float80))) * stdev + mean
        },
        .unary(.normPdf, [.any]) {
            normPdf($0)
        },
        .ternary(.normPdf, [.any, .any, .any]) {
            normPdf($0, μ: $1, σ: $2)
        },
        
        // Mark: One-variable statistics
        
        .unary(.mean, List.self) {
            Function(.sum, [$0]) / $0.count
        },
        .unary(.max, List.self) {
            Function(.max, $0.elements)
        },
        .init(.max, [.numbers]) {
            max($0.map {$0≈!})
        },
        .unary(.min, List.self) {
            Function(.min, $0.elements)
        },
        .init(.min, [.numbers]) {
            min($0.map {$0≈!})
        },
        .init(.mean, [.universal]) { nodes in
            ++nodes / nodes.count
        },
        .unary(.sumOfDiffSq, List.self) {
            try ssx($0.toNumerics())
        },
        .unary(.variance, List.self) {
            let list = try $0.toNumerics()
            return List([
                Pair("sample", variance(.sample, list)),
                Pair("population", variance(.population, list))
            ])
        },
        .unary(.stdev, List.self) {
            let list = try $0.toNumerics()

            let es = [
                Pair("Sₓ", stdev(.sample, list)),
                Pair("σₓ", stdev(.population, list))
            ]
            return List(es)
        },
        
        // Summation
        .unary(.sum, List.self) {
            sum($0.elements)
        },
        .init(.sum, [.universal]) { nodes in
            ++nodes
        },
        
        // IQR, 5 number summary
        .unary(.fiveNumberSummary, List.self) {
            let list = try $0.toNumerics()
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
        .unary(.interQuartileRange, List.self) {
            let list = try $0.toNumerics()
            let stat = try quartiles(list)
            return stat.q3 - stat.q1
        },
        .unary(.median, List.self) {
            let list = try $0.toNumerics()
            let (m, _) = median(list)
            return m
        },
        .unary(.outliers, List.self) {
            let list = try $0.toNumerics()
            let outliers = try Stat.outliers(list)
            return List([
                Pair("lower end", List(outliers.lowerEnd)),
                Pair("upper end", List(outliers.upperEnd))
            ])
        },
        .unary(.oneVar, List.self) {
            let list = try $0.toNumerics()
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
        
        .binary(.covariance, List.self, List.self) {
            let datasetX = try $0.toNumerics()
            let datasetY = try $1.toNumerics()
            
            return try List([
                Pair("sample", covariance(.sample, datasetX, datasetY)),
                Pair("population", covariance(.population, datasetX, datasetY))
            ])
        },
        .binary(.correlation, List.self, List.self) {
            let datasetX = try $0.toNumerics()
            let datasetY = try $1.toNumerics()
            
            return try correlation(datasetX, datasetY)
        },
        .binary(.determination, List.self, List.self) {
            let datasetY = try $0.toNumerics()
            let resid = try $1.toNumerics()
            
            return try determination(datasetY, resid)
        },
        .binary(.twoVar, List.self, List.self) {
            let datasetX = try $0.toNumerics()
            let datasetY = try $1.toNumerics()
            
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
            let cod = pow(cor, 2.0)
            
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
        
        .binary(.linReg, List.self, List.self) {
            let X = try $0.toNumerics()
            let Y = try $1.toNumerics()
            let result = try linearRegression(X, Y)
            
            return List([
                Pair("RegEqn", result.eqn),
                Pair("slope(m)", result.slope),
                Pair("y-int(b)", result.yIntercept),
                Pair("r²", result.cod),
                Pair("r", result.r),
                Pair("Resid", List(result.resid))
            ])
        },
        .ternary(.polyReg, Int.self, List.self, List.self) {
            let l1 = try $1.toNumerics()
            let l2 = try $2.toNumerics()
            let (eq, coefs, cod, resid) = try polynomialRegression(degrees: $0, l1, l2)
            
            return List([
                Pair("RegEqn", eq),
                Pair("Coef(s)", List(coefs)),
                Pair("R²", cod),
                Pair("Resid", List(resid)),
            ])
        },
        
        // Mark: Confidence interval
        .quaternary(.zInterval, Value.self, Value.self, Int.self, Value.self) {
            let result = try zInterval(
                sigma: $0.float80,
                statistic: $1.float80,
                sampleSize: $2,
                confidenceLevel: $3.float80
            )
            let stats: [Pair] = [
                .init("CI", List([result.ci.lowerBound, result.ci.upperBound])),
                .init("ME", result.me)
            ]
            return List(stats)
        },
        .ternary(.zInterval, Value.self, List.self, Value.self) {
            let result = try zInterval(
                sigma: $0.float80,
                sample: $1.toNumerics(),
                confidenceLevel: $2.float80
            )
            let stats: [Pair] = [
                .init("CI", List([result.ci.lowerBound, result.ci.upperBound])),
                .init("x̅", result.statistic),
                .init("ME", result.me),
                .init("Sx", result.sx),
                .init("n", result.n)
            ]
            return List(stats)
        }
    ]
}
