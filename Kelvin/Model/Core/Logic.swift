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
    .init("and", [.bool, .bool]) { nodes in
        nodes.map {
            $0 as! Bool
            }
            .reduce(true) {
                $0 && $1
        }
    },
    .init("or", [.bool, .bool]) { nodes in
        nodes.map {
            $0 as! Bool
            }
            .reduce(false) {
                $0 || $1
        }
    },
]
