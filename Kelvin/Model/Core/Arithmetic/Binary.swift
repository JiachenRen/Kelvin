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
    .binary("+", [.number, .number]) {
        bin($0, $1, +)
    },
    .binary("+", [.any, .any]) {
        $0 === $1 ? 2 * $0 : nil
    },
    .binary("+", [.number, .nan]) {
        $0 === 0 ? $1 : nil
    },
    .binary("+", [.any, .func]) {
        let fun = $1 as! Function
        switch fun.name {
        case "*":
            var args = fun.elements
            for (i, arg) in args.enumerated() {
                if arg === $0 {
                    let a = args.remove(at: i)
                    if args.count != 1 {
                        continue
                    }
                    let n = args[0] + 1
                    let s = try n.simplify()
                    if s.complexity < n.complexity {
                        return s * $0
                    } else {
                        return nil
                    }
                }
            }
        default: break
        }
        return nil
    },
    .binary("+", [.func, .func]) {
        let f1 = $0 as! Function
        let f2 = $1 as! Function

        if f1.name == f2.name {
            switch f1.name {
            case "*":
                let (n1, r1) = f1.split(by: isNumber)
                let (n2, r2) = f2.split(by: isNumber)
                if **r1 === **r2 {
                    return **r1 * (**n1 + **n2)
                }
            default:
                break
            }
        }

        return nil
    },
    

    .binary("-", [.number, .number]) {
        bin($0, $1, -)
    },
    .binary("-", [.any, .any]) {
        if $0 === $1 {
            return 0
        }
        return $0 + -$1
    },
    .unary("-", [.any]) {
        -1 * $0
    },

    .binary("*", [.number, .number]) {
        bin($0, $1, *)
    },
    .binary("*", [.any, .any]) {
        $0 === $1 ? $0 ^ 2 : nil
    },
    .binary("*", [.any, .func]) {
        let fun = $1 as! Function
        switch fun.name {
        case "^" where fun[0] === $0:
            return $0 ^ (fun[1] + 1)
        default:
            break
        }
        return nil
    },
    .binary("*", [.func, .func]) {
        let f1 = $0 as! Function
        let f2 = $1 as! Function

        if f1.name == f2.name {
            switch f1.name {
            case "^" where f1[0] === f2[0]:
                return f1[0] ^ (f1[1] + f2[1])
            default:
                break
            }
        }
        return nil
    },
    .binary("*", [.any, .int]) {
        let n = $1 as! Int
        switch n {
        case 0:
            return 0
        case 1:
            return $0
        default:
            return nil
        }
    },

    .binary("/", [.number, .number]) {
        bin($0, $1, /)
    },
    .binary("/", [.any, .any]) {
        if $0 === $1 {
            return 1
        }
        return $0 * ($1 ^ -1)
    },

    .binary("mod", [.number, .number]) {
        bin($0, $1, %)
    },

    .binary("^", [.number, .number]) {
        bin($0, $1, pow)
    },
    .binary("^", [.nan, .int]) {
        let n = $1 as! Int
        switch n {
        case 0: return 1
        case 1: return $0
        default: break
        }
        return nil
    },
    .binary("^", [.number, .nan]) {(lhs, _) in
        lhs === 0 ? 0 : nil
    },
    .binary("^", [.func, .number]) {
        guard let fun = $0 as? Function, fun.contains(where: isNumber, depth: 1) else {
            return nil
        }
        switch fun.name {
        case "*":
            let (nums, nans) = fun.split(by: isNumber)
            return (**nums ^ $1) * (**nans ^ $1)
        case "^" where fun[0] is NSNumber:
            return (fun[0] ^ $1) ^ fun[1]
        case "^" where fun[1] is NSNumber:
            return fun[0] ^ (fun[1] * $1)
        default:
            break
        }
        return nil
    },
    .binary("^", [.number, .func]) {
        let fun = $1 as! Function
        switch fun.name {
        case "*" where fun.contains(where: isNumber, depth: 1):
            let (nums, nans) = fun.split(by: isNumber)
            return ($0 ^ **nums) * ($0 ^ **nans)
        default: break
        }
        return nil
    },

]

fileprivate let isNumber: PUnary = {
    $0 is NSNumber
}

/// TODO: Implement mode exact vs approximate.
fileprivate func bin(_ lhs: Node, _ rhs: Node, _ binary: NBinary) -> Double {
    return binary(lhs≈!, rhs≈!)
}

fileprivate func d(_ node: Node) -> Double {
    return node.evaluated!.doubleValue
}

fileprivate func %(_ a: Double, _ b: Double) -> Double {
    return a.truncatingRemainder(dividingBy: b)
}
