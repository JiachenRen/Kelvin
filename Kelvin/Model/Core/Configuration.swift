//
//  Configuration.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Default configurations for built-in operations.
let defaultConfiguration: [Operation.Attribute: [String]] = [
    .commutative: [
        .mult,
        .add,
        .and,
        .or
    ],
    .preservesArguments: [
        .complexity,
        .repeat,
        .define,
        .def,
        .del,
        .if,
        .else,
        .measure,
        .try,
        .for,
        .while,
        
        
        // Functions that accepts anonymous arguments should preserve arguments.
        .pipe,
        .replace,
        .map,
        .reduce,
        .filter,
        
        .derivative,
        .implicitDifferentiation,
        .gradient,
        .directionalDifferentiation,
        
        // Mutating functions should preserve arguments.
        // Thus x += 1 won't become ... += 1
        .increment,
        .decrement,
        .mutatingAdd,
        .mutatingSub,
        .mutatingMult,
        .mutatingDiv
    ],
    .forwardCommutative: [
        .div,
        .sub
    ]
]
