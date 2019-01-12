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
    var rounding: Rounding = .exact
}

public enum Rounding {
    
    /// Constants are left as-is, and decimals are converted to fractions
    case exact
    
    /// Constants are unwrapped into their numerical values
    case approximate
}
