//
//  Boolean Logic & Equations.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

// Boolean logic and, or
let logicOperations: [Operation] = [
    .init("and", [.booleans]) {
        for n in $0 {
            if let b = n as? Bool, !b {
                return false
            }
        }
        return true
    },
    .init("or", [.booleans]) {
        for n in $0 {
            if let b = n as? Bool, b {
                return true
            }
        }
        return false
    },
]
