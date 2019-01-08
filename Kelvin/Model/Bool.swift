//
//  KBool.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

extension Bool: Leaf, NaN {
    
    var description: String {
        return "\(self)"
    }
    
    func negate() -> Bool {
        return !self
    }
    
}
