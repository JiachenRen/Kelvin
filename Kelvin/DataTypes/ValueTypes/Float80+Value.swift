//
//  Double+Value.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Float80: Value {
    
    public var float80: Float80 {
        return self
    }
    
    public var stringified: String {
        return formatted
    }
    
    public var ansiColored: String {
        return formatted.blue
    }
    
    private var formatted: String {
        // Use the proper scientific notation
        return Mode.shared.format(self)
    }
    
    /// If the double is an integer, convert it to an integer.
    public func simplify() -> Node {
        return Int(exactly: self) ?? self
    }
}
