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
    
    public static let operations: [Operation] = [
        // Distribution
        
        // tPdf/Cdf
        .binary(.tPdf, [.number, .int]) {
            try tPdf($0≈!, $1 as! Int)
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
        
        // Statistics, s stands for sample, p stands for population
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
            try ssx(($0 as! List).convertToDoubles())
        },
        .unary(.variance, [.list]) {
            let list = $0 as! List
            let variance = Stat.variance(try list.convertToDoubles())
            return List([
                Pair("sample", variance.sample),
                Pair("population", variance.population)
            ])
        },
        .unary(.stdev, [.list]) {
            let list = $0 as! List
            let stdev = Stat.stdev(try list.convertToDoubles())
            let es = [Pair("Sₓ", stdev.sample), Pair("σₓ", stdev.population)]
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
            let list = try ($0 as! List).convertToDoubles()
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
            let list = try ($0 as! List).convertToDoubles()
            let stat = try quartiles(list)
            return stat.q3 - stat.q1
        },
        .unary(.median, [.list]) {
            let list = try ($0 as! List).convertToDoubles()
            let (m, _) = median(list)
            return m
        },
        .unary(.outliers, [.list]) {
            let list = try ($0 as! List).convertToDoubles()
            let outliers = try Stat.outliers(list)
            return List([
                Pair("lower end", List(outliers.lowerEnd)),
                Pair("upper end", List(outliers.upperEnd))
            ])
        },
        .unary(.oneVar, [.list]) {
            let list = try ($0 as! List).convertToDoubles()
            let mean = Stat.mean(list)
            let sum = Stat.sum(list)
            let sumSq = Stat.sumSquared(list)
            let (s_stdev, p_stdev) = Stat.stdev(list)
            let n = list.count
            let sum5n = try Stat.fiveNSummary(list)
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
        }
    ]
}
