//
//  Unary.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let unaryOperations: [Operation] = [
    // Basic unary transcendental functions
    .unary(.log, [.number]) {
        u($0, log10)
    },
    .unary(.log2, [.number]) {
        u($0, log2)
    },
    .unary(.ln, [.number]) {
        u($0, log)
    },
    .unary(.cos, [.number]) {
        u($0, cos)
    },
    .unary(.acos, [.number]) {
        u($0, acos)
    },
    .unary(.cosh, [.number]) {
        u($0, cosh)
    },
    .unary(.sin, [.number]) {
        u($0, sin)
    },
    .unary(.asin, [.number]) {
        u($0, asin)
    },
    .unary(.sinh, [.number]) {
        u($0, sinh)
    },
    .unary(.tan, [.number]) {
        u($0, tan)
    },
    .unary(.tan, [.any]) {
        sin($0) / cos($0)
    },
    .unary(.atan, [.number]) {
        u($0, atan)
    },
    .unary(.tanh, [.number]) {
        u($0, tanh)
    },
    .unary(.sec, [.any]) {
        1 / cos($0)
    },
    .unary(.csc, [.any]) {
        1 / sin($0)
    },
    .unary(.cot, [.any]) {
        1 / tan($0)
    },
    .unary(.abs, [.number]) {
        u($0, abs)
    },
    .unary(.int, [.number]) {
        u($0, floor)
    },
    .unary(.round, [.number]) {
        u($0, round)
    },
    .unary(.negate, [.number]) {
        u($0, -)
    },
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
    .unary(.negate, [.any]) {
        $0 * -1
    },
    .unary(.sqrt, [.number]) {
        u($0, sqrt)
    },
    .unary(.sqrt, [.any]) {
        $0 ^ (Float80(0.5))
    },
    .unary(.sign, Value.self) {
        let n = $0.float80
        return n == 0 ? Float80.nan : n > 0 ? 1 : -1
    }
]

fileprivate func u(_ nodes: Node, _ unary: NUnary) -> Float80 {
    return unary(nodes≈ ?? .nan)
}

fileprivate func log10(_ a: Float80) -> Float80 {
    return log(a) / log(10)
}
