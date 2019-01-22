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
    
    // Variable/function definition and deletion
    .init("def", [.equation]) { nodes in
        guard let eq = nodes[0] as? Equation else {
            return "cannot use \(nodes[0].stringified) as definition."
        }
        if let err = eq.define() {
            return err
        }
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
        assign($0[1], to: $0[0], by: +)
    },
    .init("-=", [.var, .any]) {
        assign($0[1], to: $0[0], by: -)
    },
    .init("*=", [.var, .any]) {
        assign($0[1], to: $0[0], by: *)
    },
    .init("/=", [.var, .any]) {
        assign($0[1], to: $0[0], by: /)
    },
    
    // Consecutive execution, feed forward, flow control
    .init("if", [.any, .tuple]) { nodes in
        let node = nodes[0].simplify()
        guard let predicament = node as? Bool else {
            return nil
        }
        let tuple = nodes[1] as! Tuple

        return (predicament ? tuple.lhs : tuple.rhs).simplify() // Should this be simplified?
    },
    .init("then", [.universal]) { nodes in
        return nodes.map {
            $0.simplify()
        }.last
    },
    .init("feed", [.any, .any]) { nodes in
        let simplified = nodes[0].simplify()
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
            return "error: string index out of bounds"
        } else {
            return "\(s[n])"
        }
    },
    
    // Developer/debug functions, program input/output, compilation
    .init("complexity", [.any]) {
        $0[0].complexity
    },
    .init("eval", [.any]) {
        return $0[0].simplify()
    },
    .init("exit", []) { _ in
        exit(0)
    },
    .init("date", []) { _ in
        return "\(Date())"
    },
    .init("time", []) { _ in
        return Date().timeIntervalSince1970
    },
    .init("delay", [.number]) {
        Thread.sleep(forTimeInterval: $0[0].evaluated!.doubleValue)
        return "done"
    },
    .init("run", [.string]) {
        do {
            try Program.compileAndRun($0[0] as! String, with: nil)
        } catch let e {
            return "\(e)"
        }
        return "done"
    },
    .init("measure", [.any, .int]) {
        let n = $0[1] as! Int
        let t = Date().timeIntervalSince1970
        for _ in 0..<n {
            let _ = $0[0].simplify()
        }
        let avg = (Date().timeIntervalSince1970 - t) / Double(n)
        return Tuple("avg(s)", avg)
    },
    .init("compile", [.string]) {
        do {
            return try Compiler.compile($0[0] as! String)
        } catch CompilerError.illegalArgument(let msg) {
            return "ERR >>> illegal argument: \(msg)"
        } catch CompilerError.syntax(let msg) {
            return "ERR >>> syntax: \(msg)"
        } catch {
            return "ERR >>> unknown error"
        }
    }
]

fileprivate func assign(_ value: Node, to node: Node, by bin: Binary) -> Node {
    assert(node is Variable)
    Equation(lhs: node, rhs: bin(node, value)).define()
    return node
}
