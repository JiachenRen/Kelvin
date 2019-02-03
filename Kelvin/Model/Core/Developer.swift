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
            return KString("deleted '\(v.stringified)'")
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
    
    // Consecutive execution, pileline, flow control
    .binary(.if, [.any, .tuple]) {
        let node = try $0.simplify()
        guard let predicament = node as? Bool else {
            return nil
        }
        let tuple = $1 as! Tuple

        return try (predicament ? tuple.lhs : tuple.rhs).simplify() // Should this be simplified?
    },
    .init(.semicolon, [.universal]) { nodes in
        return try nodes.map {
            try $0.simplify()
        }.last
    },
    .binary(.pipe, [.any, .any]) {
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
    .binary(.repeat, [.any, .any]) {(lhs, rhs) in
        guard let times = try rhs.simplify() as? Int else {
            return nil
        }
        var elements = [Node]()
        (0..<times).forEach { _ in
            elements.append(lhs)
        }
        return List(elements)
    },
    .init(.copy, [.any, .number]) {
        Function(.repeat, $0)
    },
    
    // String concatenation
    .binary(.concat, [.any, .any]) {
        KString("\($0.stringified)").concat(KString("\($1.stringified)"))
    },
    .binary(.concat, [.string, .any]) {
        ($0 as! KString).concat(KString("\($1.stringified)"))
    },
    .binary(.concat, [.any, .string]) {
        KString("\($0.stringified)").concat($1 as! KString)
    },
    .binary(.concat, [.string, .string]) {
        ($0 as! KString).concat($1 as! KString)
    },
    
    // String subscript
    .binary(.get, [.string, .number]) {
        guard let s = $0 as? KString, let n = $1 as? Int else {
            return nil
        }
        if n >= s.string.count || n < 0{
            throw ExecutionError.indexOutOfBounds
        } else {
            return KString("\(s.string[n])")
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
        KString("\(Date())")
    },
    .init(.time, []) { _ in
        Date().timeIntervalSince1970
    },
    .unary(.delay, [.number]) {
        Thread.sleep(forTimeInterval: $0≈!)
        return KString("done")
    },
    .binary(.run, [.string, .string]) {
        let flag = ($0 as! KString).string
        let filePath = ($1 as! KString).string
        switch flag {
        case "-c":
            try Program.compileAndRun(filePath, with: Program.Configuration(
                scope: .useCurrent,
                retentionPolicy: .restore))
        case "-v":
            try Program.compileAndRun(filePath)
        default:
            throw ExecutionError.general(errMsg: "invalid configuration \(flag)")
        }
        return KString("done")
    },
    .unary(.run, [.string]) {
        try Program.compileAndRun(($0 as! KString).string)
        return KString("done")
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
        } catch let e as KelvinError {
            return KString(e.localizedDescription)
        }
    },
    .unary(.assert, [.bool]) {
        if !($0 as! Bool) {
            throw ExecutionError.general(errMsg: "assertion failed")
        }
        return true
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
        try Compiler.compile(($0 as! KString).string)
    },
    
    // IO
    .unary(.print, [.any]) {
        Program.io?.print($0)
        return $0
    },
    .unary(.println, [.any]) {
        Program.io?.println($0)
        return $0
    },
    .unary(.log, [.string]) {
        Program.io?.log(($0 as! KString).string)
        return $0
    }
]

fileprivate func assign(_ value: Node, to node: Node, by bin: Binary) throws -> Node {
    assert(node is Variable)
    try Equation(lhs: node, rhs: bin(node, value)).define()
    return node
}
