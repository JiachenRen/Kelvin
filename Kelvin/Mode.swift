//
//  Mode.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/9/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Mode {
    static var shared: Mode = Mode()
    
    // The rounding mode.
    var rounding: Rounding = .approximate
    
    private var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.exponentSymbol = "*10^"
        return formatter
    }()
    
    func format(_ val: Float80) -> String {
        if val < Float80(Double.greatestFiniteMagnitude) && val > Float80(Double.leastNormalMagnitude) {
            let d = Double(round(1E10 * val) / 1E10)
            if d > 1E15 || d < 1E-15 {
                return formatter.string(for: d)!
            }
            return d.description
        }
        return val.description.replacingOccurrences(of: "e+", with: "*10^")
            .replacingOccurrences(of: "e-", with: "*10^-")
    }
}

public enum Rounding {
    
    /// Constants are left as-is, and decimals are converted to fractions
    case exact
    
    /// Constants are unwrapped into their numerical values
    case approximate
}
