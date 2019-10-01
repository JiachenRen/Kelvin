//
//  Rules.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Rules contains the complex simplification rules that Kelvin algebra system uses to
/// simplify boolean logic, arithmetics, transcendental functions, etc.
class Rules: Supplier {
    static let exports: [Operation] = [
            booleanLogic,
            binaryArithmetic,
            unaryArithmetic
        ].flatMap {$0}
}
