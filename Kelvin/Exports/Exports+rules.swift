//
//  Exports+rules.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let rules: [Operation] = [ Rules.booleanLogic, Rules.binaryArithmetic, Rules.unaryArithmetic ].flatMap { $0 }
}
