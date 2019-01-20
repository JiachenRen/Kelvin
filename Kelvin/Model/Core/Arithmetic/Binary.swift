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
    .init("+", [.number, .number]) {
        bin($0, +)
    },
    .init("+", [.any, .any]) {
        $0[0] === $0[1] ? 2 * $0[0] : nil
    },
    .init("+", [.number, .nan]) {
        $0[0] === 0 ? $0[1] : nil
    },
    .init("+", [.any, .func]) {
        let fun = $0[1] as! Function
        switch fun.name {
        case "*":
            var args = fun.args.elements
            for (i, arg) in args.enumerated() {
                if arg === $0[0] {
                    let a = args.remove(at: i)
                    if args.count != 1 {
                        continue
                    }
                    let n = args[0] + 1
                    let s = n.simplify()
                    if s.complexity < n.complexity {
                        return s * $0[0]
                    } else {
                        return nil
                    }
                }
            }
        default: break
        }
        return nil
    },
    .init("+", [.func, .func]) {
        let f1 = $0[0] as! Function
        let f2 = $0[1] as! Function

        if f1.name == f2.name {
            switch f1.name {
            case "*":
                let (n1, r1) = f1.args.split(by: isNumber)
                let (n2, r2) = f2.args.split(by: isNumber)
                if **r1 === **r2 {
                    return **r1 * (**n1 + **n2)
                }
            default:
                break
            }
        }

        return nil
    },
    .init("+", [.list, .list]) {
        join(by: "+", $0[0], $0[1])
    },
    .init("+", [.list, .any]) {
        map(by: "+", $0[0], $0[1])
    },

    .init("-", [.number, .number]) {
        bin($0, -)
    },
    .init("-", [.any, .any]) {
        if $0[0] === $0[1] {
            return 0
        }
        return $0[0] + -$0[1]
    },
    .init("-", [.any]) {
        -1 * $0[0]
    },
    .init("-", [.list, .list]) {
        join(by: "-", $0[0], $0[1])
    },
    .init("-", [.list, .any]) {
        map(by: "-", $0[0], $0[1])
    },

    .init("*", [.number, .number]) {
        bin($0, *)
    },
    .init("*", [.var, .var]) {
        $0[0] === $0[1] ? $0[0] ^ 2 : nil
    },
    .init("*", [.var, .func]) {
        let fun = $0[1] as! Function
        let v = $0[0] as! Variable
        switch fun.name {
        case "^" where fun.args[0] === v:
            return v ^ (fun.args[1] + 1)
        default:
            break
        }
        return nil
    },
    .init("*", [.func, .func]) {
        let f1 = $0[0] as! Function
        let f2 = $0[1] as! Function

        if f1.name == f2.name {
            switch f1.name {
            case "^" where f1.args[0] === f2.args[0]:
                return f1.args[0] ^ (f1.args[1] + f2.args[1])
            default:
                break
            }
        }
        return nil
    },
    .init("*", [.any, .number]) {
        let n = $0[1] as! NSNumber
        switch n {
        case 0:
            return 0
        case 1:
            return $0[0]
        default:
            return nil
        }
    },
    .init("*", [.list, .list]) {
        join(by: "*", $0[0], $0[1])
    },
    .init("*", [.list, .any]) {
        map(by: "*", $0[0], $0[1])
    },

    .init("/", [.number, .number]) {
        bin($0, /)
    },
    .init("/", [.any, .any]) {
        if $0[0] === $0[1] {
            return 1
        }
        return $0[0] * ($0[1] ^ -1)
    },
    .init("/", [.list, .list]) {
        join(by: "/", $0[0], $0[1])
    },
    .init("/", [.list, .any]) {
        map(by: "/", $0[0], $0[1])
    },

    .init("mod", [.number, .number]) {
        bin($0, %)
    },
    .init("mod", [.list, .list]) {
        join(by: "mod", $0[0], $0[1])
    },
    .init("mod", [.list, .any]) {
        map(by: "mod", $0[0], $0[1])
    },

    .init("^", [.number, .number]) {
        bin($0, pow)
    },
    .init("^", [.nan, .number]) {
        if let n = $0[1] as? Int {
            switch n {
            case 0: return 1
            case 1: return $0[0]
            default: break
            }
        }
        return nil
    },
    .init("^", [.number, .nan]) {
        $0[0] === 0 ? 0 : nil
    },
    .init("^", [.func, .number]) {
        let fun = $0[0] as! Function
        switch fun.name {
        case "*":
            if fun.contains(where: isNumber, depth: 1) {
                let (nums, nans) = fun.args.split(by: isNumber)
                return (**nums ^ $0[1]) * (**nans ^ $0[1])
            }
        default: break
        }
        return nil
    },
    .init("^", [.number, .func]) {
        let fun = $0[1] as! Function
        switch fun.name {
        case "*" where fun.args.contains(where: isNumber, depth: 1):
            let (nums, nans) = fun.args.split(by: isNumber)
            return ($0[0] ^ **nums) * ($0[0] ^ **nans)
        default: break
        }
        return nil
    },
    .init("^", [.list, .list]) {
        join(by: "^", $0[0], $0[1])
    },
    .init("^", [.list, .any]) {
        map(by: "^", $0[0], $0[1])
    },

]

fileprivate let isNumber: PUnary = {
    $0 is NSNumber
}

fileprivate func bin(_ nodes: [Node], _ binary: NBinary) -> Double {
    return nodes.map {
                $0.evaluated?.doubleValue ?? .nan
            }
            .reduce(nil) {
                $0 == nil ? $1 : binary($0!, $1)
            }!
}

fileprivate func join(by bin: String, _ l1: Node, _ l2: Node) -> Node {
    let l1 = l1 as! List
    let l2 = l2 as! List

    if l1.count != l2.count {
        return "list dimension mismatch"
    }

    return l1.join(with: l2, by: bin)
}

fileprivate func map(by bin: String, _ l: Node, _ n: Node) -> Node {
    let l = l as! List

    let elements = l.elements.map {
        Function(bin, [$0, n])
    }
    return List(elements)
}

fileprivate func %(_ a: Double, _ b: Double) -> Double {
    return a.truncatingRemainder(dividingBy: b)
}
