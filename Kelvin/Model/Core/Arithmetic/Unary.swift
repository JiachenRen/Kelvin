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
    .init("log", [.number]) {
        u($0, log10)
    },
    .init("log2", [.number]) {
        u($0, log2)
    },
    .init("ln", [.number]) {
        u($0, log)
    },
    .init("cos", [.number]) {
        u($0, cos)
    },
    .init("acos", [.number]) {
        u($0, acos)
    },
    .init("cosh", [.number]) {
        u($0, cosh)
    },
    .init("sin", [.number]) {
        u($0, sin)
    },
    .init("asin", [.number]) {
        u($0, asin)
    },
    .init("sinh", [.number]) {
        u($0, sinh)
    },
    .init("tan", [.number]) {
        u($0, tan)
    },
    .init("atan", [.number]) {
        u($0, atan)
    },
    .init("tanh", [.number]) {
        u($0, tanh)
    },
    .init("sec", [.any]) {
        1 / cos($0[0])
    },
    .init("csc", [.any]) {
        1 / sin($0[0])
    },
    .init("cot", [.any]) {
        1 / tan($0[0])
    },
    .init("abs", [.number]) {
        u($0, abs)
    },
    .init("int", [.number]) {
        u($0, floor)
    },
    .init("round", [.number]) {
        u($0, round)
    },
    .init("negate", [.number]) {
        u($0, -)
    },
    .init("negate", [.func]) {
        var fun = $0[0] as! Function
        switch fun.name {
        case "nagate":
            return fun.args[0]
        case "+":
            let elements = fun.args.elements.map {
                $0 * -1
            }
            return Function(fun.name, elements)
        case "*":
            var args = fun.args.elements
            args.append(-1)
            return *args
        default: break
        }
        return nil
    },
    .init("negate", [.var]) {
        $0[0] * -1
    },
    .init("sqrt", [.number]) {
        u($0, sqrt)
    },
    .init("sqrt", [.any]) {
        $0[0] ^ (1 / 2)
    },
    .init("sign", [.number]) {
        let n = $0[0].evaluated!.doubleValue
        return n == 0 ? Double.nan : n > 0 ? 1 : -1
    }
]

fileprivate func u(_ nodes: [Node], _ unary: NUnary) -> Double {
    return unary(nodes[0].evaluated?.doubleValue ?? .nan)
}

fileprivate func log10(_ a: Double) -> Double {
    return log(a) / log(10)
}
