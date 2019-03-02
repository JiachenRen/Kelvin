//
//  Arithmetic.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let binaryOperations: [Operation] = [
    // Basic binary arithmetic
    .binary(.add, [.number, .number]) {
        bin($0, $1, +)
    },
    .binary(.add, [.any, .any]) {
        $0 === $1 ? 2 * $0 : nil
    },
    .binary(.add, [.number, .nan]) {
        $0 === 0 ? $1 : nil
    },
    .binary(.add, Node.self, Function.self) {(lhs, fun) in
        switch fun.name {
        case .mult:
            var args = fun.elements
            for (i, arg) in args.enumerated() {
                if arg === lhs {
                    let a = args.remove(at: i)
                    if args.count != 1 {
                        continue
                    }
                    let n = args[0] + 1
                    let s = try n.simplify()
                    if s.complexity < n.complexity {
                        return s * lhs
                    } else {
                        return nil
                    }
                }
            }
        default: break
        }
        return nil
    },
    .binary(.add, Function.self, Function.self) {(lhs, rhs) in
        if lhs.name == rhs.name {
            switch lhs.name {
            case .mult:
                let (n1, r1) = lhs.split(by: isNumber)
                let (n2, r2) = rhs.split(by: isNumber)
                if **r1 === **r2 {
                    return **r1 * (**n1 + **n2)
                }
            default:
                break
            }
        }
        return nil
    },
    

    .binary(.sub, [.number, .number]) {
        bin($0, $1, -)
    },
    .binary(.sub, [.any, .any]) {
        if $0 === $1 {
            return 0
        }
        return $0 + -$1
    },
    .unary(.sub, [.any]) {
        -1 * $0
    },

    .binary(.mult, [.number, .number]) {
        bin($0, $1, *)
    },
    .binary(.mult, [.any, .any]) {
        $0 === $1 ? $0 ^ 2 : nil
    },
    .binary(.mult, Node.self, Function.self) {(lhs, fun) in
        switch fun.name {
        case .exp where fun[0] === lhs:
            return lhs ^ (fun[1] + 1)
        default:
            break
        }
        return nil
    },
    .binary(.mult, Function.self, Function.self) {(lhs, rhs) in
        if lhs.name == rhs.name {
            switch lhs.name {
            case .exp where lhs[0] === rhs[0]:
                return lhs[0] ^ (lhs[1] + rhs[1])
            default:
                break
            }
        }
        return nil
    },
    .binary(.mult, Node.self, Int.self) {(lhs, rhs) in
        switch rhs {
        case 0:
            return 0
        case 1:
            return lhs
        default:
            return nil
        }
    },

    .binary(.div, [.number, .number]) {
        bin($0, $1, /)
    },
    .binary(.div, [.any, .any]) {
        if $0 === $1 {
            return 1
        }
        return $0 * ($1 ^ -1)
    },

    .binary(.mod, [.number, .number]) {
        bin($0, $1, %)
    },

    .binary(.exp, [.number, .number]) {
        bin($0, $1, pow)
    },
    .binary(.exp, [.nan, .int]) {
        let n = $1 as! Int
        switch n {
        case 0: return 1
        case 1: return $0
        default: break
        }
        return nil
    },
    .binary(.exp, [.number, .nan]) {(lhs, _) in
        lhs === 0 ? 0 : nil
    },
    .binary(.exp, Function.self, Value.self) {(fun, rhs) in
        guard fun.contains(where: isNumber, depth: 1) else {
            return nil
        }
        switch fun.name {
        case .mult:
            let (nums, nans) = fun.split(by: isNumber)
            return (**nums ^ rhs) * (**nans ^ rhs)
        case .exp where fun[0] is Value:
            return (fun[0] ^ rhs) ^ fun[1]
        case .exp where fun[1] is Value:
            return fun[0] ^ (fun[1] * rhs)
        default:
            break
        }
        return nil
    },
    .binary(.exp, Value.self, Function.self) {(lhs, fun) in
        switch fun.name {
        case .mult where fun.contains(where: isNumber, depth: 1):
            let (nums, nans) = fun.split(by: isNumber)
            return (lhs ^ **nums) * (lhs ^ **nans)
        default: break
        }
        return nil
    },

]

fileprivate let isNumber: PUnary = {
    $0 is Value
}

/// TODO: Implement mode exact vs approximate.
fileprivate func bin(_ lhs: Node, _ rhs: Node, _ binary: NBinary) -> Float80 {
    return binary(lhs≈!, rhs≈!)
}

fileprivate func d(_ node: Node) -> Float80 {
    return node.evaluated!.float80
}

fileprivate func %(_ a: Float80, _ b: Float80) -> Float80 {
    return a.truncatingRemainder(dividingBy: b)
}
