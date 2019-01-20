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
        "*",
        "+",
        "and",
        "or"
    ],
    .preservesArguments: [
        "complexity",
        "repeat",
        "feed",
        "exec",
        "define",
        "def",
        "del",
        "if"
    ],
    .forwardCommutative: [
        "/",
        "-"
    ]
]
