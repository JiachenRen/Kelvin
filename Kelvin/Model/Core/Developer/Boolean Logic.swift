//
//  Boolean Logic.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Developer {
    
    /// Boolean logic and, or
    /// - Todo: Implement boolean logic simplification
    static let booleanLogicOperations: [Operation] = [
        .init(.and, [.booleans]) {
            for n in $0 {
                if let b = n as? Bool, !b {
                    return false
                }
            }
            return true
        },
        .init(.or, [.booleans]) {
            for n in $0 {
                if let b = n as? Bool, b {
                    return true
                }
            }
            return false
        },
        .binary(.xor, [.any, .any]) {
            (!!$0 &&& $1) ||| ($0 &&& !!$1)
        },
        .unary(.not, [.bool]) {
            !($0 as! Bool)
        },
    ]
}
