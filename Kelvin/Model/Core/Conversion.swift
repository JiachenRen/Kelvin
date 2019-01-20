//
//  Conversion.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let conversionOperations: [Operation] = [
    .init("degrees", [.any]) {
        $0[0] / 180 * (try! Variable("pi"))
    },
    .init("pct", [.any]) {
        $0[0] / 100
    },
]
