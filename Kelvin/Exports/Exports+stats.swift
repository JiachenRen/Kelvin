//
//  Exports+stats.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/28/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let stats = Stat.exports
}

extension Stat {
    static let exports: [Operation] = [
        
        // Mark: Distribution
        
        // tPdf, tCdf, and invt
        .binary(.invT, Number.self, Int.self) {
            try invT($0.float80, $1)
        },
        .binary(.tPdf, Number.self, Int.self) {
            try tPdf($0.float80, $1)
        },
        .binary(.tCdf, Number.self, Int.self) {
            try tCdf($0.float80, $1)
        },
        .ternary(.tCdf, Number.self, Number.self, Int.self) {
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
        .ternary(.binomPdf, [.node, .node, .node]) {
            binomPdf(trials: $0, prSuccess: $1, $2)
        },
        .binary(.binomPdf, Int.self, Node.self) {
            Vector(binomPdf(trials: $0, prSuccess: $1))
        },
        .quaternary(.binomCdf, Int.self, Node.self, Int.self, Int.self) {
            try binomCdf(trials: $0, prSuccess: $1, lowerBound: $2, upperBound: $3)
        },
        
        // normCdf from -∞ to x
        .unary(.normCdf, Number.self) {
            Float80(normCdf(Double($0.float80)))
        },
        
        // normCdf from a to b, centered at zero with stdev of 1
        .binary(.normCdf, Number.self, Number.self) {
            Float80(normCdf(from: Double($0≈!), to: Double($1≈!)))
        },
        
        // normCdf from a to b, centered at zero with stdev of 1
        .init(.normCdf, [.number, .number, .number, .number]) {
            let args: [Double] = $0.map {Double($0≈!)}
            return Float80(normCdf(from: args[0], to: args[1], μ: args[2], σ: args[3]))
        },
        .ternary(.randNorm, Number.self, Number.self, Int.self) {
            let elements = randNorm(μ: $0.float80, σ: $1.float80, n: $2)
            return Vector(elements)
        },
        .ternary(.invNorm, Number.self, Number.self, Number.self) {
            let stdev = $2
            let mean = $1
            return try Float80(invNorm(Double($0.float80))) * stdev + mean
        },
        .unary(.normPdf, [.node]) {
            normPdf($0)
        },
        .ternary(.normPdf, [.node, .node, .node]) {
            normPdf($0, μ: $1, σ: $2)
        },
        
        // Mark: One-variable statistics
        
        .unary(.mean, Vector.self) {
            Function(.sum, [$0]) / $0.count
        },
        .unary(.max, Vector.self) {
            Function(.max, $0.elements)
        },
        .init(.max, [.init(.number, multiplicity: .any)]) {
            max($0.map {$0≈!})
        },
        .unary(.min, Vector.self) {
            Function(.min, $0.elements)
        },
        .init(.min, [.init(.number, multiplicity: .any)]) {
            min($0.map {$0≈!})
        },
        .init(.mean, [.init(.node, multiplicity: .any)]) { nodes in
            ++nodes / nodes.count
        },
        .unary(.sumOfDiffSq, Vector.self) {
            try ssx($0.toFloat80s())
        },
        .unary(.variance, Vector.self) {
            let list = try $0.toFloat80s()
            return Vector([
                Pair("sample", variance(.sample, list)),
                Pair("population", variance(.population, list))
            ])
        },
        .unary(.stdev, Vector.self) {
            let list = try $0.toFloat80s()

            let es = [
                Pair("Sₓ", stdev(.sample, list)),
                Pair("σₓ", stdev(.population, list))
            ]
            return Vector(es)
        },
        
        // Summation
        .unary(.sum, Vector.self) {
            sum($0.elements)
        },
        .init(.sum, [.init(.node, multiplicity: .any)]) { nodes in
            ++nodes
        },
        
        // IQR, 5 number summary
        .unary(.fiveNumberSummary, Vector.self) {
            let list = try $0.toFloat80s()
            let sum5n = try fiveNSummary(list)
            let stats: [Pair] = [
                .init("min", sum5n[0]),
                .init("q1", sum5n[1]),
                .init("median", sum5n[2]),
                .init("q3", sum5n[3]),
                .init("max", sum5n[4])
            ]
            return Vector(stats)
        },
        .unary(.interQuartileRange, Vector.self) {
            let list = try $0.toFloat80s()
            let stat = try quartiles(list)
            return stat.q3 - stat.q1
        },
        .unary(.median, Vector.self) {
            let list = try $0.toFloat80s()
            let (m, _) = median(list)
            return m
        },
        .unary(.outliers, Vector.self) {
            let list = try $0.toFloat80s()
            let outliers = try Stat.outliers(list)
            return Vector([
                Pair("lower end", Vector(outliers.lowerEnd)),
                Pair("upper end", Vector(outliers.upperEnd))
            ])
        },
        .unary(.oneVar, Vector.self) {
            let list = try $0.toFloat80s()
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
            
            return Vector(stats)
        },
        
        // Mark: Two-variable statistics
        
        .binary(.covariance, Vector.self, Vector.self) {
            let datasetX = try $0.toFloat80s()
            let datasetY = try $1.toFloat80s()
            
            return try Vector([
                Pair("sample", covariance(.sample, datasetX, datasetY)),
                Pair("population", covariance(.population, datasetX, datasetY))
            ])
        },
        .binary(.correlation, Vector.self, Vector.self) {
            let datasetX = try $0.toFloat80s()
            let datasetY = try $1.toFloat80s()
            
            return try correlation(datasetX, datasetY)
        },
        .binary(.determination, Vector.self, Vector.self) {
            let datasetY = try $0.toFloat80s()
            let resid = try $1.toFloat80s()
            
            return try determination(datasetY, resid)
        },
        .binary(.twoVar, Vector.self, Vector.self) {
            let datasetX = try $0.toFloat80s()
            let datasetY = try $1.toFloat80s()
            
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
            
            return Vector(stats)
        },
        
        // Mark: Regression
        
        .binary(.linReg, Vector.self, Vector.self) {
            let X = try $0.toFloat80s()
            let Y = try $1.toFloat80s()
            let result = try linearRegression(X, Y)
            
            return Vector([
                Pair("RegEqn", result.eqn),
                Pair("slope(m)", result.slope),
                Pair("y-int(b)", result.yIntercept),
                Pair("r²", result.cod),
                Pair("r", result.r),
                Pair("Resid", Vector(result.resid))
            ])
        },
        .ternary(.polyReg, Int.self, Vector.self, Vector.self) {
            let l1 = try $1.toFloat80s()
            let l2 = try $2.toFloat80s()
            let (eq, coefs, cod, resid) = try polynomialRegression(degrees: $0, l1, l2)
            
            return Vector([
                Pair("RegEqn", eq),
                Pair("Coef(s)", Vector(coefs)),
                Pair("R²", cod),
                Pair("Resid", Vector(resid)),
            ])
        },
        
        // Mark: Confidence intervals
        
        .quaternary(.zInterval, Number.self, Number.self, Int.self, Number.self) {
            let result = try zInterval(
                sigma: $0.float80,
                mean: $1.float80,
                sampleSize: $2,
                confidenceLevel: $3.float80
            )
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("ME", result.me),
                .init("z", result.z)
            ]
            return Vector(stats)
        },
        .ternary(.zInterval, Number.self, Vector.self, Number.self) {
            let result = try zInterval(
                sigma: $0.float80,
                sample: $1.toFloat80s(),
                confidenceLevel: $2.float80
            )
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("x̅", result.oneVar.mean),
                .init("ME", result.me),
                .init("Sx", result.oneVar.sx),
                .init("n", result.oneVar.n),
                .init("z", result.z)
            ]
            return Vector(stats)
        },
        .quaternary(.tInterval, Number.self, Number.self, Int.self, Number.self) {
            let result = try tInterval(
                mean: $0.float80,
                sx: $1.float80,
                sampleSize: $2,
                confidenceLevel: $3.float80
            )
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("ME", result.me),
                .init("SE", result.se),
                .init("t", result.t),
                .init("df", result.df),
            ]
            return Vector(stats)
        },
        .binary(.tInterval, Vector.self, Number.self) {
            let result = try tInterval(sample: $0.toFloat80s(), confidenceLevel: $1.float80)
            // (result.ci, statistic, result.me, result.df, sx, n)
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("x̅", result.oneVar.mean),
                .init("ME", result.me),
                .init("SE", result.se),
                .init("t", result.t),
                .init("df", result.df),
                .init("Sx", result.oneVar.sx),
                .init("n", result.oneVar.n)
            ]
            return Vector(stats)
        },
        .ternary(.zIntervalOneProp, Int.self, Int.self, Number.self) {
            let result = try zIntervalOneProp(
                successes: $0,
                sampleSize: $1,
                confidenceLevel: $2.float80
            )
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("p̂", result.pHat),
                .init("ME", result.me),
                .init("SE", result.se)
            ]
            return Vector(stats)
        },
        .init(.zIntervalTwoSamp, [.number, .number, .vector, .vector, .number]) {
            let (sigma1, sigma2, l1, l2, cl) = try (
                $0[0]≈!,
                $0[1]≈!,
                ($0[2] as! Vector).toFloat80s(),
                ($0[3] as! Vector).toFloat80s(),
                $0[4]≈!
            )
            let result = try zIntervalTwoSamp(
                sigma1: sigma1,
                sigma2: sigma2,
                sample1: l1,
                sample2: l2,
                confidenceLevel: cl
            )
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("x̅1 - x̅2", result.meanDiff),
                .init("ME", result.me),
                .init("x̅1", result.twoVar.mean1),
                .init("x̅2", result.twoVar.mean2),
                .init("Sx1", result.twoVar.sx1),
                .init("Sx2", result.twoVar.sx2),
                .init("n1", result.twoVar.n1),
                .init("n2", result.twoVar.n2),
            ]
            return Vector(stats)
        },
        .init(.zIntervalTwoSamp, [.number, .number, .number, .int, .number, .int, .number]) {
            let (sigma1, sigma2, stat1, n1, stat2, n2, c) = (
                $0[0].evaluated!.float80,
                $0[1].evaluated!.float80,
                $0[2].evaluated!.float80,
                $0[3] as! Int,
                $0[4].evaluated!.float80,
                $0[5] as! Int,
                $0[6].evaluated!.float80
            )
            let result = try zIntervalTwoSamp(
                sigma1: sigma1,
                sigma2: sigma2,
                mean1: stat1,
                sampleSize1: n1,
                mean2: stat2,
                sampleSize2: n2,
                confidenceLevel: c
            )
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("x̅1 - x̅2", result.meanDiff),
                .init("ME", result.me),
                .init("σDiff", result.sigmaDiff),
            ]
            return Vector(stats)
        },
        .init(.tIntervalTwoSamp, [.number, .number, .int, .number, .number, .int, .number]) {
            let (mean1, sx1, n1, mean2, sx2, n2, c) = (
                $0[0].evaluated!.float80,
                $0[1].evaluated!.float80,
                $0[2] as! Int,
                $0[3].evaluated!.float80,
                $0[4].evaluated!.float80,
                $0[5] as! Int,
                $0[6].evaluated!.float80
            )
            let result = try tIntervalTwoSamp(
                mean1: mean1,
                sx1: sx1,
                sampleSize1: n1,
                mean2: mean2,
                sx2: sx2,
                sampleSize2: n2,
                confidenceLevel: c
            )
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("x̅1 - x̅2", result.meanDiff),
                .init("SE", result.se),
                .init("ME", result.me),
                .init("df", result.df)
            ]
            return Vector(stats)
        },
        .ternary(.tIntervalTwoSamp, Vector.self, Vector.self, Number.self) {
            let result = try tIntervalTwoSamp(
                sample1: $0.toFloat80s(),
                sample2: $1.toFloat80s(),
                confidenceLevel: $2.float80
            )
            let stats: [Pair] = [
                .init("CI", Vector([result.ci.lowerBound, result.ci.upperBound])),
                .init("x̅1 - x̅2", result.meanDiff),
                .init("SE", result.se),
                .init("ME", result.me),
                .init("df", result.df),
                .init("x̅1", result.twoVar.mean1),
                .init("x̅2", result.twoVar.mean2),
                .init("Sx1", result.twoVar.sx1),
                .init("Sx2", result.twoVar.sx2),
                .init("n1", result.twoVar.n1),
                .init("n2", result.twoVar.n2),
            ]
            return Vector(stats)
        }
    ]
}
