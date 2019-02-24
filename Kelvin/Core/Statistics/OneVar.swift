//
//  Stat.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import GameKit

// OneVar statistics
public extension Stat {
    
    public static func outliers(_ dataset: [Float80]) throws -> (lowerEnd: [Float80], upperEnd: [Float80]) {
        let stats = try quartiles(dataset)
        let iqr = stats.q3 - stats.q1
        let ut = stats.q3 + 1.5 * iqr
        let lt = stats.q1 - 1.5 * iqr
        
        let leOutliers = dataset.filter {
            $0 < lt
        }
        
        let ueOutliers = dataset.filter {
            $0 > ut
        }
        
        return (leOutliers, ueOutliers)
    }
    
    public static func fiveNSummary(
        _ dataset: [Float80],
        isSorted: Bool = false) throws -> [Float80] {
        
        var dataset = dataset
        let c = dataset.count
        if c == 0 {
            throw ExecutionError.general(errMsg: "cannot perform summary statistics on empty list.")
        }
        
        if !isSorted {
            dataset = dataset.sorted {
                $0 < $1
            }
        }
        
        let min = dataset.first!
        let max = dataset.last!
        
        let m = try quartiles(dataset, isSorted: true)
        
        return [min, m.q1, m.m, m.q3, max]
    }
    
    public static func quartiles(
        _ dataset: [Float80],
        isSorted: Bool = false) throws -> (q1: Float80, m: Float80, q3: Float80) {
        
        var dataset = dataset
        let c = dataset.count
        if c == 0 {
            throw ExecutionError.general(errMsg: "cannot perform summary statistics on empty list.")
        }
        
        if !isSorted {
            dataset = dataset.sorted {
                $0 < $1
            }
        }
        
        let (m, i) = median(dataset, isSorted: true)
        var l = dataset, r = dataset
        let idx = i ?? c / 2
        l = Array(dataset.prefix(upTo: idx))
        r = Array(dataset.suffix(from: idx + ((c % 2 == 0) ? 0 : 1)))
        
        let (q1, _) = median(l, isSorted: true)
        let (q3, _) = median(r, isSorted: true)
        return (q1, m, q3)
    }
    
    public static func median(
        _ dataset: [Float80],
        isSorted: Bool = false) -> (Float80, idx: Int?) {
        
        var dataset = dataset
        let c = dataset.count
        if c == 0 {
            return (.nan, nil)
        }
        
        if !isSorted {
            dataset = dataset.sorted {
                $0 < $1
            }
        }
        
        if c % 2 == 0 {
            let m = ((dataset[c / 2] + dataset[c / 2 - 1])) / 2
            return (m, nil)
        } else {
            let i = c / 2
            return (dataset[i], i)
        }
    }
    
    /// Sum of difference squared.
    public static func ssx(_ dataset: [Float80]) -> Float80 {
        
        // Calculate average.
        let sum: Float80 = dataset.reduce(0) {
            $0 + $1
        }
        let avg: Float80 = sum / Float80(dataset.count)
        
        // Sum of squared differences
        return dataset.map {pow($0 - avg, 2)}
            .reduce(0) {$0 + $1}
    }
    
    public static func max(_ dataset: [Float80]) -> Float80 {
        var max: Float80 = -.infinity
        for n in dataset {
            if n > max {
                max = n
            }
        }
        return max
    }
    
    public static func min(_ dataset: [Float80]) -> Float80 {
        var min: Float80 = .infinity
        for n in dataset {
            if n < min {
                min = n
            }
        }
        return min
    }
    
    public static func sum(_ nodes: [Node]) -> Node {
        var nSum: Float80 = 0
        var nans = [Node]()
        
        for element in nodes {
            if element is Int {
                nSum += Float80(element as! Int)
            } else if element is Float80 {
                nSum += element as! Float80
            } else {
                nans.append(element)
            }
        }
        return ++nans + nSum
    }
    
    public static func sumSquared(_ dataset: [Float80]) -> Float80 {
        return dataset.map {pow($0, 2)}.reduce(0) {$0 + $1}
    }
    
    public static func variance(_ type: DatasetType, _ dataset: [Float80]) -> Float80 {
        let s = ssx(dataset)
        let c = Float80(dataset.count)
        switch type {
        case .sample:
            return s / (c - 1)
        case .population:
            return s / c
        }
    }
    
    public static func stdev(_ type: DatasetType, _ dataset: [Float80]) -> Float80 {
        return sqrt(variance(type, dataset))
    }
    
    public static func mean(_ dataset: [Float80]) -> Float80 {
        return dataset.reduce(0) {$0 + $1} / Float80(dataset.count)
    }
}
