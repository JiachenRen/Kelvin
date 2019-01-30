//
//  FlowControl.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let developerOperations: [Operation] = [
    
    // Boolean logic and, or
    // - Todo: Implement boolean logic simplification
    .init(.and, [.booleans]) {
        for n in $0 {
            if let b = n as? Bool, !b {
                return false
            }
        }
        return true
    },
    .init(.or, [.booleans]) {
        for n in $0 {
            if let b = n as? Bool, b {
                return true
            }
        }
        return false
    },
    .binary(.xor, [.any, .any]) {
        (!!$0 &&& $1) ||| ($0 &&& !!$1)
    },
    .unary(.not, [.bool]) {
        !($0 as! Bool)
    },
    
    // Variable/function definition and deletion
    .unary(.def, [.equation]) {
        guard let eq = $0 as? Equation else {
            throw ExecutionError.general(errMsg: "cannot use \($0.stringified) as definition.")
        }
        try eq.define()
        return eq.lhs
    },
    .binary(.define, [.any, .any]) {
        return Function(.def, [Equation(lhs: $0, rhs: $1)])
    },
    .unary(.del, [.var]) {
        if let v = $0 as? Variable {
            Variable.delete(v.name)
            Operation.remove(v.name)
            return "deleted '\(v.stringified)'"
        }
        return nil
    },
    
    // C like syntactic shorthand
    .unary(.increment, [.var]) {
        $0 +== 1
    },
    .unary(.decrement, [.var]) {
        $0 -== 1
    },
    .binary(.mutatingAdd, [.var, .any]) {
        try assign($1, to: $0, by: +)
    },
    .binary(.mutatingSub, [.var, .any]) {
        try assign($1, to: $0, by: -)
    },
    .binary(.mutatingMult, [.var, .any]) {
        try assign($1, to: $0, by: *)
    },
    .binary(.mutatingDiv, [.var, .any]) {
        try assign($1, to: $0, by: /)
    },
    
    // Consecutive execution, feed forward, flow control
    .binary(.if, [.any, .tuple]) {
        let node = try $0.simplify()
        guard let predicament = node as? Bool else {
            return nil
        }
        let tuple = $1 as! Tuple

        return try (predicament ? tuple.lhs : tuple.rhs).simplify() // Should this be simplified?
    },
    .init(.then, [.universal]) { nodes in
        return try nodes.map {
            try $0.simplify()
        }.last
    },
    .binary(.feed, [.any, .any]) {
        let simplified = try $0.simplify()
        return $1.replacingAnonymousArgs(with: [simplified])
    },
    .binary(.replace, [.any, .any]) {
        var simplified = try $0.simplify()
    
        var pairs = [(Node, Node)]()
        
        func getPair(_ eq: Equation) throws -> (Node, Node) {
            return try (eq.lhs.simplify(), eq.rhs.simplify())
        }
        if let eq = $1 as? Equation {
            pairs.append(try getPair(eq))
        } else if let list = $1 as? List {
            pairs.append(contentsOf:
                try list.elements.map {node -> (Node, Node) in
                if let eq = node as? Equation {
                    return try getPair(eq)
                }
                throw ExecutionError.incompatibleList(.equation)
            })
        }
    
        for (target, replacement) in pairs {
            simplified = simplified.replacing(by: {_ in replacement}) {
                $0 === target
            }
        }
        
        return simplified
    },
    .binary(.repeat, [.any, .number]) {(lhs, rhs) in
        let times = Int(rhs≈!)
        var elements = [Node]()
        (0..<times).forEach { _ in
            elements.append(lhs)
        }
        return List(elements)
    },
    .init(.copy, [.any, .number]) {
        return Function(.repeat, $0)
    },
    
    // String concatenation
    .binary(.concat, [.any, .any]) {
        return "\($0)\($1)"
    },
    
    // String subscript
    .binary(.get, [.string, .number]) {
        guard let s = $0 as? String, let n = $1 as? Int else {
            return nil
        }
        if n >= s.count || n < 0{
            throw ExecutionError.indexOutOfBounds
        } else {
            return "\(s[n])"
        }
    },
    
    // Developer/debug functions, program input/output, compilation
    .unary(.complexity, [.any]) {
        $0.complexity
    },
    .unary(.eval, [.any]) {
        try $0.simplify()
    },
    .init(.exit, []) { _ in
        exit(0)
    },
    .init(.date, []) { _ in
        "\(Date())"
    },
    .init(.time, []) { _ in
        Date().timeIntervalSince1970
    },
    .unary(.delay, [.number]) {
        Thread.sleep(forTimeInterval: $0≈!)
        return "done"
    },
    .binary(.run, [.string, .string]) {
        let flag = $0 as! String
        let filePath = $1 as! String
        switch flag {
        case "-c":
            return List(try Program.compileAndRun(filePath, with: Program.Configuration(
                verbose: false,
                scope: .useCurrent,
                retentionPolicy: .restore)).outputs
                .filter {$0 !== "\n"})
        case "-v":
            try Program.compileAndRun(filePath, with: nil)
        default:
            throw ExecutionError.general(errMsg: "invalid configuration \(flag)")
        }
        return "done"
    },
    .unary(.run, [.string]) {
        try Program.compileAndRun($0 as! String, with: nil)
        return "done"
    },
    .unary(.try, [.tuple]) {
        let tuple = $0 as! Tuple
        do {
            return try tuple.lhs.simplify()
        } catch {
            return try tuple.rhs.simplify()
        }
    },
    .unary(.try, [.any]) {
        do {
            return try $0.simplify()
        } catch ExecutionError.general(let msg) {
            return msg
        } catch CompilerError.illegalArgument(let msg) {
            return msg
        } catch CompilerError.syntax(let msg) {
            return msg
        }
    },
    .binary(.measure, [.any, .int]) {
        let n = $1 as! Int
        let t = Date().timeIntervalSince1970
        for _ in 0..<n {
            let _ = try $0.simplify()
        }
        let avg = (Date().timeIntervalSince1970 - t) / Double(n)
        return Tuple("avg(s)", avg)
    },
    .unary(.compile, [.string]) {
        try Compiler.compile($0 as! String)
    }
]

fileprivate func assign(_ value: Node, to node: Node, by bin: Binary) throws -> Node {
    assert(node is Variable)
    try Equation(lhs: node, rhs: bin(node, value)).define()
    return node
}
