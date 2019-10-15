//
//  Rules+unaryArit.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Rules {
    /// Unary arithmetic rules
    static let unaryArithmetic: [Operation] = [
        .unary(.negate, Function.self) {fun in
            switch fun.name {
            case .negate:
                return fun[0]
            case .add:
                let elements = fun.elements.map {
                    $0 * -1
                }
                return Function(fun.name, elements)
            case .mult:
                var args = fun.elements
                args.append(-1)
                return *args
            default: break
            }
            return nil
        },
        .unary(.negate, [.node]) {
            $0 * -1
        },
        .unary(.sqrt, [.node]) {
            $0 ^ (Float80(0.5))
        },
        .unary(.sec, [.node]) {
            1 / cos($0)
        },
        .unary(.csc, [.node]) {
            1 / sin($0)
        },
        .unary(.cot, [.node]) {
            1 / tan($0)
        },
        .unary(.tan, [.node]) {
            sin($0) / cos($0)
        },
    ]
}
