//
//  Definitions.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/13/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

typealias Definition = ([Node]) -> Node?

/**
 Pre-defined operations with signatures that are resolved and assigned
 to function definitions during compilation.
 */
public let definitions: [Operation] = [
    
    // Basic binary arithmetic
    .init("+", [.number, .number], syntax:
    .init(.infix, priority: .addition, operator: "+")) {bin($0, +)},
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
                if f1.contains(where: isNumber, depth: 1) && f2.contains(where: isNumber, depth: 1) {
                    let (n1, r1) = f1.args.split(by: isNumber)
                    let (n2, r2) = f2.args.split(by: isNumber)
                    if **r1 === **r2 {
                        return **r1 * (**n1 + **n2)
                    }
                }
            default:
                break
            }
        }
        
        return nil
    },
    
    .init("-", [.number, .number], syntax:
    .init(.infix, priority: .addition, operator: "-")) {bin($0, -)},
    .init("-", [.any, .any]) {
        if $0[0] === $0[1] {
            return 0
        }
        return $0[0] + -$0[1]
    },
    
    .init("*", [.number, .number], syntax:
    .init(.infix, priority: .product, operator: "*")) {bin($0, *)},
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
    
    .init("/", [.number, .number], syntax:
    .init(.infix, priority: .product, operator: "/")) {bin($0, /)},
    .init("/", [.any, .any]) {
        if $0[0] === $0[1] {
            return 1
        }
        return $0[0] * ($0[1] ^ -1)
    },
    
    .init("mod", [.number, .number], syntax:
    .init(.infix, priority: .product, operator: "%")) {bin($0, %)},
    .init("^", [.number, .number], syntax:
    .init(.infix, priority: .exponent, operator: "^")) {bin($0, pow)},
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
    
    
    // Basic unary transcendental functions
    .init("log", [.number]) {u($0, log10)},
    .init("log2", [.number]) {u($0, log2)},
    .init("ln", [.number]) {u($0, log)},
    .init("cos", [.number]) {u($0, cos)},
    .init("sin", [.number]) {u($0, sin)},
    .init("tan", [.number]) {u($0, tan)},
    .init("int", [.number]) {u($0, floor)},
    .init("round", [.number]) {u($0, round)},
    .init("negate", [.number]) {u($0, -)},
    .init("negate", [.func]) {
        var fun = $0[0] as! Function
        switch fun.name {
        case "nagate":
            return fun.args[0]
        case "+":
            fun.args.elements = fun.args.elements.map{$0 * -1}
            return fun.flatten()
        case "*":
            var args = fun.args.elements
            args.append(-1)
            return Function("*", args)
        default: break
        }
        return nil
    },
    .init("negate", [.var]){$0[0] * -1},
    .init("sqrt", [.number], syntax:
    .init(.prefix, priority: .exponent, operator: "√")) {u($0, sqrt)},
    
    // Postfix operations
    .init("degrees", [.any], syntax:
    .init(.postfix, priority: .exponent, operator: "°")) {
        return $0[0] / 180 * v("pi")
    },
    .init("factorial", [.number], syntax:
    .init(.postfix, priority: .exponent, operator: "!")) {
        if let i = Int(exactly: $0[0].evaluated!.doubleValue) {
            return factorial(Double(i))
        }
        return "can only perform factorial on an integer"
    },
    .init("pct", [.any], syntax:
    .init(.postfix, priority: .exponent)) {
        return $0[0] / 100
    },
    
    // Equality, inequality, and equations
    .init("=", [.any, .any], syntax:
    .init(.infix, priority: .equation, operator: "=")) {
        return Equation(lhs: $0[0], rhs: $0[1])
    },
    .init("<", [.any, .any], syntax:
    .init(.infix, priority: .equality, operator: "<")) {
        return Equation(lhs: $0[0], rhs: $0[1], mode: .lessThan)
    },
    .init(">", [.any, .any], syntax:
    .init(.infix, priority: .equality, operator: ">")) {
        return Equation(lhs: $0[0], rhs: $0[1], mode: .greaterThan)
    },
    .init(">=", [.any, .any], syntax:
    .init(.infix, priority: .equality, shorthand: ">=", operator: "≥")) {
        return Equation(lhs: $0[0], rhs: $0[1], mode: .greaterThanOrEquals)
    },
    .init("<=", [.any, .any], syntax:
    .init(.infix, priority: .equality, shorthand: "<=", operator: "≤")) {
        return Equation(lhs: $0[0], rhs: $0[1], mode: .lessThanOrEquals)
    },
    .init("equals", [.any, .any], syntax:
    .init(.infix, priority: .equality, shorthand: "==")) {nodes in
        return nodes[0] === nodes[1]
    },
    
    // Boolean logic and, or
    .init("and", [.bool, .bool], syntax:
    .init(.infix, priority: .and, shorthand: "&&")) {nodes in
        return nodes.map{$0 as! Bool}
            .reduce(true){$0 && $1}
    },
    .init("or", [.bool, .bool], syntax:
    .init(.infix, priority: .or, shorthand: "||")) {nodes in
        return nodes.map{$0 as! Bool}
            .reduce(false){$0 || $1}
    },
    
    // Variable/function definition and deletion
    .init("define", [.equation], syntax:
    .init(.prefix, priority: .definition, shorthand: ":=")) {nodes in
        if let err = (nodes[0] as? Equation)?.define() {
            return err
        }
        return "done"
    },
    .init("define", [.any, .any], syntax:
    .init(.infix, shorthand: ":=")) {nodes in
        return Function("define", [Equation(lhs: nodes[0], rhs: nodes[1])])
    },
    .init("del", [.var], syntax:
    .init(.prefix)) {nodes in
        if let v = nodes[0] as? Variable {
            Variable.delete(v.name)
            Operation.remove(v.name)
            return "deleted '\(v)'"
        }
        return nil
    },
    
    // Summation
    .init("sum", [.list]) {nodes in
        return Function("+", (nodes[0] as! List).elements)
    },
    .init("sum", [.universal]) {nodes in
        return Function("+", nodes)
    },
    
    // Random number generation
    .init("random", []) {nodes in
        return Double.random(in: 0...1)
    },
    .init("random", [.number, .number]) {nodes in
        let lb = nodes[0].evaluated!.doubleValue
        let ub = nodes[1].evaluated!.doubleValue
        return Double.random(in: lb...ub)
    },
    
    // List related operations
    .init("list", [.universal]) {List($0)},
    .init("get", [.list, .number], syntax:
    .init(.infix)) {nodes in
        let list = nodes[0] as! List
        let idx = Int(nodes[1].evaluated!.doubleValue)
        if idx >= list.count {
            return "error: index out of bounds"
        } else {
            return list[idx]
        }
    },
    .init("size", [.list], syntax: .init(.prefix)) {
        return ($0[0] as! List).count
    },
    .init("map", [.list, .any], syntax:
    .init(.infix, priority: .execution, operator: "|")) {nodes in
        let list = nodes[0] as! List
        let updated = list.elements.map {element in
            nodes[1].replacing(by: {_ in element}) {
                $0 === v("$")
            }
        }
        return List(updated)
    },
    
    // Average
    .init("avg", [.list]) {nodes in
        let l = (nodes[0] as! List).elements
        return Function("+", l) / l.count
    },
    .init("avg", [.universal]) {nodes in
        return Function("+", nodes) / nodes.count
    },
    
    // Consecutive execution, feed forward, flow control
    .init("then", [.universal], syntax:
    .init(.infix, operator: ";")) {nodes in
        return nodes.map{$0.simplify()}.last
    },
    .init("feed", [.any, .any], syntax:
    .init(.infix, shorthand: "->")) {nodes in
        let simplified = nodes[0].simplify()
        return nodes.last!.replacing(by: {_ in simplified}) {
            $0 === v("$")
        }
    },
    .init("repeat", [.any, .number], syntax:
    .init(.infix, priority: .repeat, operator: "…")) {nodes in
        let times = Int(nodes[1].evaluated!.doubleValue)
        var elements = [Node]()
        (0..<times).forEach{_ in elements.append(nodes[0])}
        return List(elements)
    },
    .init("copy", [.any, .number], syntax:
    .init(.infix, priority: .repeat)) {nodes in
        return Function("repeat", nodes)
    },
    
    // Developer/debug functions
    .init("complexity", [.any], syntax:
    .init(.prefix)) {$0[0].complexity},
    .init("eval", [.any], syntax: .init(.prefix)) {
        $0[0].evaluated?.doubleValue ?? Double.nan
    },
]

let defaultConfig: [Operation.Flag: [String]] = [
    .commutative: [
        "*",
        "+",
        "and",
        "or"
    ],
    .preservesArguments: [
        "complexity",
        "repeat",
        "feed",
        "exec",
        "define"
    ],
    .forwardCommutative: [
        "/",
        "-"
    ]
]

/// Numerical unary operation
typealias NUnary = (Double) -> Double

/// Numerical binary operation
typealias NBinary = (Double, Double) -> Double

fileprivate let isNumber: PUnary = {$0 is NSNumber}

fileprivate func v(_ n: String) -> Variable {
    return try! Variable(n)
}

fileprivate func bin(_ nodes: [Node], _ binary: NBinary) -> Double {
    return nodes.map{$0.evaluated?.doubleValue ?? .nan}
        .reduce(nil) {$0 == nil ? $1 : binary($0!, $1)}!
}

fileprivate func u(_ nodes: [Node], _ unary: NUnary) -> Double {
    return unary(nodes[0].evaluated?.doubleValue ?? .nan)
}

fileprivate func log10(_ a: Double) -> Double {
    return log(a) / log(10)
}

fileprivate func %(_ a: Double, _ b: Double) -> Double {
    return a.truncatingRemainder(dividingBy: b)
}

/// A very concise definition of factorial.
fileprivate func factorial(_ n: Double) -> Double {
    return n == 0 ? 1 : n * factorial(n - 1)
}
