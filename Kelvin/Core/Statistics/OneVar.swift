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
    
    public static func outliers(_ list: [Double]) throws -> (lowerEnd: [Double], upperEnd: [Double]) {
        let stats = try quartiles(list)
        let iqr = stats.q3 - stats.q1
        let ut = stats.q3 + 1.5 * iqr
        let lt = stats.q1 - 1.5 * iqr
        
        let leOutliers = list.filter {
            $0 < lt
        }
        
        let ueOutliers = list.filter {
            $0 > ut
        }
        
        return (leOutliers, ueOutliers)
    }
    
    public static func fiveNSummary(
        _ numbers: [Double],
        isSorted: Bool = false) throws -> [Double] {
        
        var numbers = numbers
        let c = numbers.count
        if c == 0 {
            throw ExecutionError.general(errMsg: "cannot perform summary statistics on empty list.")
        }
        
        if !isSorted {
            numbers = numbers.sorted {
                $0 < $1
            }
        }
        
        let min = numbers.first!
        let max = numbers.last!
        
        let m = try quartiles(numbers, isSorted: true)
        
        return [min, m.q1, m.m, m.q3, max]
    }
    
    public static func quartiles(
        _ numbers: [Double],
        isSorted: Bool = false) throws -> (q1: Double, m: Double, q3: Double) {
        
        var numbers = numbers
        let c = numbers.count
        if c == 0 {
            throw ExecutionError.general(errMsg: "cannot perform summary statistics on empty list.")
        }
        
        if !isSorted {
            numbers = numbers.sorted {
                $0 < $1
            }
        }
        
        let (m, i) = median(numbers, isSorted: true)
        var l = numbers, r = numbers
        let idx = i ?? c / 2
        l = Array(numbers.prefix(upTo: idx))
        r = Array(numbers.suffix(from: idx + 1))
        
        let (q1, _) = median(l, isSorted: true)
        let (q3, _) = median(r, isSorted: true)
        return (q1, m, q3)
    }
    
    public static func median(
        _ numbers: [Double],
        isSorted: Bool = false) -> (Double, idx: Int?) {
        
        var numbers = numbers
        let c = numbers.count
        if c == 0 {
            return (.nan, nil)
        }
        
        if !isSorted {
            numbers = numbers.sorted {
                $0 < $1
            }
        }
        
        if c % 2 == 0 {
            let m = ((numbers[c / 2] + numbers[c / 2 - 1])) / 2
            return (m, nil)
        } else {
            let i = c / 2
            return (numbers[i], i)
        }
    }
    
    /// Sum of difference squared.
    public static func ssx(_ numbers: [Double]) -> Double {
        
        // Calculate average.
        let sum: Double = numbers.reduce(0) {
            $0 + $1
        }
        let avg: Double = sum / Double(numbers.count)
        
        // Sum of squared differences
        return numbers.map {pow($0 - avg, 2)}
            .reduce(0) {$0 + $1}
    }
    
    public static func max(_ numbers: [Double]) -> Double {
        var max: Double = -.infinity
        for n in numbers {
            if n > max {
                max = n
            }
        }
        return max
    }
    
    public static func min(_ numbers: [Double]) -> Double {
        var min: Double = .infinity
        for n in numbers {
            if n < min {
                min = n
            }
        }
        return min
    }
    
    public static func sum(_ nodes: [Node]) -> Node {
        var nSum: Double = 0
        var nans = [Node]()
        
        for element in nodes {
            if element is Int {
                nSum += Double(element as! Int)
            } else if element is Double {
                nSum += element as! Double
            } else {
                nans.append(element)
            }
        }
        return ++nans + nSum
    }
    
    public static func sumSquared(_ numbers: [Double]) -> Double {
        return numbers.map {pow($0, 2)}.reduce(0) {$0 + $1}
    }
    
    public static func variance(_ numbers: [Double]) -> (sample: Double, population: Double) {
        let s = ssx(numbers)
        let c = Double(numbers.count)
        return (s / (c - 1), s / c)
    }
    
    public static func stdev(_ numbers: [Double]) -> (sample: Double, population: Double) {
        let v = variance(numbers)
        return (sqrt(v.sample), sqrt(v.population))
    }
    
    public static func mean(_ numbers: [Double]) -> Double {
        return numbers.reduce(0) {$0 + $1} / Double(numbers.count)
    }
}
