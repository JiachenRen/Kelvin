//
//  Int+Value.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Int: Value {
    public var doubleValue: Double {
        return Double(self)
    }
    
    public var ansiColored: String {
        return "\(self)".blue
    }
}
