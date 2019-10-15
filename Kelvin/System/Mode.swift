//
//  Mode.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/9/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Mode {
    public static var shared: Mode = Mode()
    
    /// The rounding mode, either `.approximate`, `.exact`, or `.auto`
    public var rounding: Rounding = .approximate
    public var extrapolation: Extrapolation = .advanced
    
    private var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.exponentSymbol = "*10^"
        return formatter
    }()
    
    func format(_ val: Float80) -> String {
        let absVal = abs(val)
        if absVal < Float80(Double.greatestFiniteMagnitude) && absVal > Float80(Double.leastNormalMagnitude) {
            let d = Double(round(1E10 * val) / 1E10)
            let absD = abs(d)
            if absD > 1E15 || absD < 1E-4 {
                return formatter.string(for: d)!
            }
            return d.description
        }
        return val.description.replacingOccurrences(of: "e+", with: "*10^")
            .replacingOccurrences(of: "e-", with: "*10^-")
    }
    
    public enum Extrapolation: String {
        /// Simplifies all boolean logic, algebraic expressions, etc. automatically.
        case advanced
        /// Turns off all automatic simplification (code runs much faster).
        case basic
    }
    
    public enum Rounding: String {
        /// Converts everything to fractions, if exact results cannot be obtained, original expression is retained.
        case exact
        /// Converts everything to floating point; results are approximate.
        case approximate
        /// Kelvin CAS decides whether to leave results as exact or approximate based on user input.
        case auto
    }
}


