//
//  Bool+Value.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Bool: Value {
    public var doubleValue: Double {
        return Double(self ? 1 : 0)
    }
    
    public var ansiColored: String {
        return self ? "\(self)".green.bold : "\(self)".red.bold
    }
}
