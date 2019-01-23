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
    .init("and", [.booleans]) {
        for n in $0 {
            if let b = n as? Bool, !b {
                return false
            }
        }
        return true
    },
    .init("or", [.booleans]) {
        for n in $0 {
            if let b = n as? Bool, b {
                return true
            }
        }
        return false
    },
    .init("xor", [.any, .any]) {
        (!!$0[0] &&& $0[1]) ||| ($0[0] &&& !!$0[1])
    },
    .init("not", [.bool]) {
        !($0[0] as! Bool)
    },
    
    // Variable/function definition and deletion
    .init("def", [.equation]) { nodes in
        guard let eq = nodes[0] as? Equation else {
            throw ExecutionError.general(errMsg: "cannot use \(nodes[0].stringified) as definition.") 
        }
        try eq.define()
        return eq.lhs
    },
    .init("define", [.any, .any]) { nodes in
        return Function("def", [Equation(lhs: nodes[0], rhs: nodes[1])])
    },
    .init("del", [.var]) { nodes in
        if let v = nodes[0] as? Variable {
            Variable.delete(v.name)
            Operation.remove(v.name)
            return "deleted '\(v.stringified)'"
        }
        return nil
    },
    
    // C like syntactic shorthand
    .init("++", [.var]) {
        $0[0] +== 1
    },
    .init("--", [.var]) {
        $0[0] -== 1
    },
    .init("+=", [.var, .any]) {
        try assign($0[1], to: $0[0], by: +)
    },
    .init("-=", [.var, .any]) {
        try assign($0[1], to: $0[0], by: -)
    },
    .init("*=", [.var, .any]) {
        try assign($0[1], to: $0[0], by: *)
    },
    .init("/=", [.var, .any]) {
        try assign($0[1], to: $0[0], by: /)
    },
    
    // Consecutive execution, feed forward, flow control
    .init("if", [.any, .tuple]) { nodes in
        let node = try nodes[0].simplify()
        guard let predicament = node as? Bool else {
            return nil
        }
        let tuple = nodes[1] as! Tuple

        return try (predicament ? tuple.lhs : tuple.rhs).simplify() // Should this be simplified?
    },
    .init("then", [.universal]) { nodes in
        return try nodes.map {
            try $0.simplify()
        }.last
    },
    .init("feed", [.any, .any]) { nodes in
        let simplified = try nodes[0].simplify()
        return nodes.last!.replacingAnonymousArgs(with: [simplified])
    },
    .init("repeat", [.any, .number]) { nodes in
        let times = Int(nodes[1].evaluated!.doubleValue)
        var elements = [Node]()
        (0..<times).forEach { _ in
            elements.append(nodes[0])
        }
        return List(elements)
    },
    .init("copy", [.any, .number]) { nodes in
        return Function("repeat", nodes)
    },
    
    // String concatenation
    .init("concat", [.any, .any]) {
        return "\($0[0])\($0[1])"
    },
    
    // String subscript
    .init("get", [.string, .number]) {
        guard let s = $0[0] as? String, let n = $0[1] as? Int else {
            return nil
        }
        if n >= s.count || n < 0{
            throw ExecutionError.indexOutOfBounds
        } else {
            return "\(s[n])"
        }
    },
    
    // Developer/debug functions, program input/output, compilation
    .init("complexity", [.any]) {
        $0[0].complexity
    },
    .init("eval", [.any]) {
        try $0[0].simplify()
    },
    .init("exit", []) { _ in
        exit(0)
    },
    .init("date", []) { _ in
        "\(Date())"
    },
    .init("time", []) { _ in
        Date().timeIntervalSince1970
    },
    .init("delay", [.number]) {
        Thread.sleep(forTimeInterval: $0[0].evaluated!.doubleValue)
        return "done"
    },
    .init("run", [.string, .string]) {
        let flag = $0[0] as! String
        let filePath = $0[1] as! String
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
    .init("run", [.string]) {
        try Program.compileAndRun($0[0] as! String, with: nil)
        return "done"
    },
    .init("try", [.tuple]) {
        let tuple = $0[0] as! Tuple
        do {
            return try tuple.lhs.simplify()
        } catch {
            return try tuple.rhs.simplify()
        }
    },
    .init("try", [.any]) {
        do {
            return try $0[0].simplify()
        } catch ExecutionError.general(let msg) {
            return msg
        } catch CompilerError.illegalArgument(let msg) {
            return msg
        } catch CompilerError.syntax(let msg) {
            return msg
        }
    },
    .init("measure", [.any, .int]) {
        let n = $0[1] as! Int
        let t = Date().timeIntervalSince1970
        for _ in 0..<n {
            let _ = try $0[0].simplify()
        }
        let avg = (Date().timeIntervalSince1970 - t) / Double(n)
        return Tuple("avg(s)", avg)
    },
    .init("compile", [.string]) {
        try Compiler.compile($0[0] as! String)
    }
]

fileprivate func assign(_ value: Node, to node: Node, by bin: Binary) throws -> Node {
    assert(node is Variable)
    try Equation(lhs: node, rhs: bin(node, value)).define()
    return node
}
