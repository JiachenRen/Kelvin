//
//  Algebra.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Algebra {
    
    /// Algebraic operations (factorization, expansion)
    public static let operations: [Operation] = [
        .unary(.factorize, [.any]) {
            try factorize($0)
        },
    ]
    
}
