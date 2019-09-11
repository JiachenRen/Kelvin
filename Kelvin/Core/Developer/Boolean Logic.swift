//
//  Boolean Logic.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Developer {
    
    /// Boolean logic and, or, not, xor,
    /// - Todo: Implement boolean logic simplification
    static let booleanLogicOperations: [Operation] = [
        
        // Elementary boolean operator set
        .init(.and, [.booleans]) {
            for n in $0 {
                if !(n as! Bool) {
                    return false
                }
            }
            return true
        },
        .init(.or, [.booleans]) {
            for n in $0 {
                if n as! Bool {
                    return true
                }
            }
            return false
        },
        .unary(.not, Bool.self) {
            !$0
        },
        
        // Advanced boolean operator set
        .binary(.xor, [.any, .any]) {
            (!!$0 &&& $1) ||| ($0 &&& !!$1)
        },
        .binary(.nor, [.any, .any]) {
            !!($0 ||| $1)
        },
        .binary(.nand, [.any, .any]) {
            !!($0 &&& $1)
        },
    ]
}
