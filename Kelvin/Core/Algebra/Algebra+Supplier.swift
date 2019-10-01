//
//  Algebra+Supplier.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Algebra: Supplier {
    /// Export algebraic operations (factorization, expansion)
    static let exports: [Operation] = [
        .unary(.factorize, [.any]) {
            try factorize($0)
        },
        .unary(.expand, [.any]) {
            expand($0)
        },
    ]
}
