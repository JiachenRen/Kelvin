//
//  Boolean Logic.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Developer {
    
    /// Boolean logic and, or, not, xor,
    /// - Todo: Implement boolean logic simplification
    static let booleanLogicOperations: [Operation] = [
        
        // Elementary boolean operator set
        .init(.and, [.booleans]) {
            for n in $0 {
                if !(n as! Bool) {
                    return false
                }
            }
            return true
        },
        .init(.or, [.booleans]) {
            for n in $0 {
                if n as! Bool {
                    return true
                }
            }
            return false
        },
        .unary(.not, Bool.self) {
            !$0
        },
        
        // Advanced boolean operator set
        .binary(.xor, [.any, .any]) {
            (!!$0 &&& $1) ||| ($0 &&& !!$1)
        },
        .binary(.nor, [.any, .any]) {
            !!($0 ||| $1)
        },
        .binary(.nand, [.any, .any]) {
            !!($0 &&& $1)
        },
        
        // Boolean simplification logic
        .binary(.or, [.any, .any]) {
            if $0 === false {
                // a or false is a
                return $1
            } else if $0 === true {
                // a or true is true
                return true
            } else if $0 === $1 {
                // a or a is a
                return $0
            }
            return nil
        },
        .binary(.and, [.any, .any]) {
            if $0 === false {
                // false and _ is false
                return false
            } else if $0 === true {
                // true && a is true
                return $1
            } else if $0 === $1 {
                // a and a is a
                return $0
            }
            return nil
        },
        .unary(.not, [.func]) {
            let fun = try Assert.cast($0, to: Function.self)
            // Apply De Morgan's laws
            switch fun.name {
            case .or:
                // not (a or b) is (not a and not b)
                return Function(.and, fun.args.map {!!$0})
            case .and:
                // not (a and b) is (not a or not b)
                return Function(.or, fun.args.map {!!$0})
            case .not:
                // not (not a) is a
                return fun.args[0]
            default:
                return nil
            }
        },
        .binary(.and, [.any, .func]) {
            (node, fun) in
            let fun = try Assert.cast(fun, to: Function.self)
            switch fun.name {
            case .or where fun.args.contains(where: {$0 === node}, depth: 1) :
                // Base case, a and (a or b) is a
                return node
            case .or:
                let original = Function(.and, [node, fun])
                
                // Try expanding and then simplify
                // a and (b or c) = (a and b) or (a and c)
                let trial = try pack(.or, fun.args.map {
                    try (node &&& $0).simplify()
                })
                    
                if trial.complexity < original.complexity {
                    return trial
                }
                
                // Try expanding and simplifying by the rule
                // a and (b or (c and d)) == a and (b or c) and (b or d)
                for (i, n) in fun.args.elements.enumerated() {
                    if let nestedAnd = n as? Function, nestedAnd.name == .and {
                        var arguments = fun.args.elements
                        arguments.remove(at: i)
                        let or = pack(.or, arguments)
                        var simplified = false
                        let trial = try pack(.and, nestedAnd.args.map {
                            let org = (or ||| $0) &&& node
                            let sim = try org.simplify()
                            if sim.complexity < org.complexity {
                                simplified = true
                            }
                            return sim
                        })
                        if simplified {
                            return trial
                        }
                    }
                }
            case .not:
                // a and (not a) is false
                if let arg = fun.args.elements.first, arg === node {
                    return false
                }
            default:
                break
            }
            return nil
        },
        .binary(.or, [.any, .func]) {
            (node, fun) in
            let fun = try Assert.cast(fun, to: Function.self)
            switch fun.name {
                // - Todo: !a or (a and b), a or (!a and b)
            case .and where fun.args.contains(where: {$0 === node}, depth: 1):
                // Base case, a or (a and b) is a
                return node
            case .and:
                let original = Function(.or, [node, fun])
                
                // Try expanding and then simplify
                // a or (b and c) = (a or b) and (a or c)
                let trial = try pack(.and, fun.args.map {
                    try (node ||| $0).simplify()
                })
                    
                if trial.complexity < original.complexity {
                    return trial
                }
                
                // Try expanding and simplifying by the rule
                // a or (b and (c or d)) == a or (b and c) or (b and d)
                for (i, n) in fun.args.elements.enumerated() {
                    if let nestedOr = n as? Function, nestedOr.name == .or {
                        var arguments = fun.args.elements
                        arguments.remove(at: i)
                        let and = pack(.and, arguments)
                        var simplified = false
                        let trial = try pack(.or, nestedOr.args.map {
                            let org = (and &&& $0) ||| node
                            let sim = try org.simplify()
                            if sim.complexity < org.complexity {
                                simplified = true
                            }
                            return sim
                        })
                        if simplified {
                            return trial
                        }
                    }
                }
            case .not:
                // a or (not a) is true
                if let arg = fun.args.elements.first, arg === node {
                    return true
                }
            default:
                break
            }
            return nil
        },
        .binary(.and, Function.self, Function.self) {
            (fun1, fun2) in
            if fun1.name == fun2.name && fun1.name == .or {
                // (a or c) and (b or c) is (a and b) or c
                var leftArgs = fun1.args.elements
                var rightArgs = fun2.args.elements
                let commonTerms = intersection(&leftArgs, &rightArgs)
                if commonTerms.count > 0 {
                    let disjoint = pack(.or, leftArgs) &&& pack(.or, rightArgs)
                    return disjoint ||| pack(.or, commonTerms)
                }
            }
            return nil
        },
        .binary(.or, Function.self, Function.self) {
            (fun1, fun2) in
            if fun1.name == fun2.name && fun1.name == .and {
                // (a and b) or (c and d) is (a or c) and b
                var leftArgs = fun1.args.elements
                var rightArgs = fun2.args.elements
                let commonTerms = intersection(&leftArgs, &rightArgs)
                if commonTerms.count > 0 {
                    let conjunct = pack(.and, leftArgs) ||| pack(.and, rightArgs)
                    let result = conjunct &&& pack(.and, commonTerms)
                    return result
                }
            }
            return nil
        }
    ]
}

/// Pack elements into the specified function.
/// - Parameter fun: Name of the function
/// - Parameter elements: Parameters of the functionf
fileprivate func pack(_ fun: String, _ elements: [Node]) -> Node {
    assert(elements.count > 0)
    if elements.count == 1 {
        return elements.first!
    }
    return Function(fun, elements)
}

fileprivate func intersection(_ list1: inout [Node], _ list2: inout [Node]) -> [Node] {
    var intersection: [Node] = []
    for i in (0..<list1.count).reversed() {
        inner: for j in (0..<list2.count).reversed() {
            if list1[i] === list2[j] {
                list1.remove(at: i)
                let e = list2.remove(at: j)
                intersection.append(e)
                break inner
            }
        }
    }
    return intersection
}
