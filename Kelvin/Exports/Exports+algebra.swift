//
//  Exports+algebra.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let algebra: [Operation] = Algebra.exports
}

extension Algebra {
    static let exports: [Operation] = [
        .unary(.factorize, [.any]) { try factorize($0) },
        .unary(.expand, [.any]) { expand($0) },
    ]
}


