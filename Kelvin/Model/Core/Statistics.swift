//
//  Stat.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let statOperations: [Operation] = [
    // Statistics, s stands for sample, p stands for population
    .unary("avg", [.list]) {
        return Function("sum", [$0]) / ($0 as! List).count
    },
    .unary("max", [.list]) {
        return Function("max", ($0 as! List).elements)
    },
    .init("max", [.numbers]) {
        let numbers = $0.map {
            $0≈!
        }
        var max: Double = -.infinity
        for n in numbers {
            if n > max {
                max = n
            }
        }
        return max
    },
    .unary("min", [.list]) {
        return Function("min", ($0 as! List).elements)
    },
    .init("min", [.numbers]) {
        let numbers = $0.map {
            $0≈!
        }
        var min: Double = .infinity
        for n in numbers {
            if n < min {
                min = n
            }
        }
        return min
    },
    .init("avg", [.universal]) { nodes in
        return ++nodes / nodes.count
    },
    .unary("ssx", [.list]) {
        return try ssx($0 as! List)
    },
    .unary("variance", [.list]) {
        let list = $0 as! List
        let s = try ssx(list)
        guard let n = s as? Double else {
            // If we cannot calculate sum of difference squared,
            // return the error message.
            return s
        }

        return List([
            Tuple("sample", n / (list.count - 1)),
            Tuple("population", n / list.count)
        ])
    },
    .init("stdev", [.list]) { nodes in
        let vars = try Function("variance", nodes).simplify()

        guard let elements = (vars as? List)?.elements else {

            // Forward error message
            return vars
        }

        let vs: [Double] = elements.map {
                    $0 as! Tuple
                }
                .map {
                    $0≈!
                }

        let stdevs = vs.map(sqrt)
        assert(stdevs.count == 2)

        let es = [Tuple("Sₓ", stdevs[0]), Tuple("σₓ", stdevs[1])]
        return List(es)
    },

    // Summation
    .unary("sum", [.list]) {
        let list = $0 as! List
        var nSum: Double = 0
        var nans = [Node]()

        for element in list.elements {
            if element is Int {
                nSum += Double(element as! Int)
            } else if element is Double {
                nSum += element as! Double
            } else {
                nans.append(element)
            }
        }
        return ++nans + nSum
    },
    .init("sum", [.universal]) { nodes in
        return ++nodes
    },
    
    // IQR, 5 number summary
    .unary("sum5n", [.list]) {
        let list = try ($0 as! List).convertToDoubles()
        return try fiveNSummary(list)
    },
    .unary("iqr", [.list]) {
        let list = try ($0 as! List).convertToDoubles()
        let stat = try quartiles(list)
        return stat.q3 - stat.q1
    },
    .unary("median", [.list]) {
        let list = try ($0 as! List).convertToDoubles()
        let (m, _) = median(list)
        return m
    },
    .unary("outliers", [.list]) {
        let list = try ($0 as! List).convertToDoubles()
        return try outliers(list)
    }
]

fileprivate func outliers(_ list: [Double]) throws -> List {
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
    
    // TODO: Confidence interval, margin of error.
    // Margin of error = z-score (from confidence interval) * stdev of sampling dist.
    // Confidence interval = estimate +/- margin of error.
}

fileprivate func fiveNSummary(_ list: [Double]) throws -> Node {
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

fileprivate func quartiles(_ numbers: [Double]) throws -> (q1: Double, m: Double, q3: Double) {
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

fileprivate func median(_ numbers: [Double]) -> (Double, idx: Int?) {
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
fileprivate func ssx(_ list: List) throws -> Node {
    let nodes = list.elements
    for e in nodes {
        if !(e is NSNumber) {
            throw ExecutionError.general(errMsg: "every element in the list must be a number.")
        }
    }

    let numbers: [Double] = nodes.map {
        $0≈!
    }

    // Calculate avg.
    let sum: Double = numbers.reduce(0) {
        $0 + $1
    }
    let avg: Double = sum / Double(nodes.count)

    // Sum of squared differences
    return numbers.map {
                pow($0 - avg, 2)
            }
            .reduce(0) { (a: Double, b: Double) in
                return a + b
            }
}
