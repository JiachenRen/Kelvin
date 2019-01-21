//
//  FlowControl.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let developerOperations: [Operation] = [
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
