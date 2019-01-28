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
    
    public static func outliers(_ list: [Double]) throws -> List {
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
        
        return List([
            Tuple("lower end", List(leOutliers)),
            Tuple("upper end", List(ueOutliers))
        ])
    }
    
    public static func fiveNSummary(_ list: [Double]) throws -> Node {
        let c = list.count
        if c == 0 {
            throw ExecutionError.general(errMsg: "cannot perform summary statistics on empty list.")
        }
        
        let min = list.first!
        let max = list.last!
        
        let m = try quartiles(list)
        
        let summary: [Tuple] = [
            .init("min", min),
            .init("q1", m.q1),
            .init("median", m.m),
            .init("q3", m.q3),
            .init("max", max)
        ]
        
        return List(summary)
    }
    
    public static func quartiles(_ numbers: [Double]) throws -> (q1: Double, m: Double, q3: Double) {
        let c = numbers.count
        if c == 0 {
            throw ExecutionError.general(errMsg: "cannot perform summary statistics on empty list.")
        }
        
        let (m, i) = median(numbers)
        var l = numbers, r = numbers
        let idx = i ?? c / 2
        l = Array(numbers.prefix(upTo: idx))
        r = Array(numbers.suffix(from: idx + 1))
        
        let (q1, _) = median(l)
        let (q3, _) = median(r)
        return (q1, m, q3)
    }
    
    public static func median(_ numbers: [Double]) -> (Double, idx: Int?) {
        let c = numbers.count
        if c == 0 {
            return (.nan, nil)
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
    public static func ssx(_ numbers: [Double]) throws -> Node {
        
        // Calculate average.
        let sum: Double = numbers.reduce(0) {
            $0 + $1
        }
        let avg: Double = sum / Double(numbers.count)
        
        // Sum of squared differences
        return numbers.map {
            pow($0 - avg, 2)
            }
            .reduce(0) { (a: Double, b: Double) in
                return a + b
        }
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
}
