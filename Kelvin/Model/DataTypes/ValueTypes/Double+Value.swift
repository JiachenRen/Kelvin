//
//  Double+Value.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Double: Value {
    var isInteger: Bool {
        return floor(self) == self
    }
    
    public var doubleValue: Double {
        return self
    }
    
    public var stringified: String {
        
        // Use the proper scientific notation
        return "\(self)".replacingOccurrences(of: "e+", with: "*10^")
            .replacingOccurrences(of: "e-", with: "*10^-")
    }
    
    /// If the double is an integer, convert it to an integer.
    public func simplify() -> Node {
        return Int(exactly: self) ?? self
    }
}
