//
//  FlowControl.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Developer {
    static let operations: [Operation] = [
        stringOperations,
        flowControlOperations,
        assignmentOperations,
        booleanLogicOperations,
        utilityOperations,
        debugOperations
    ].flatMap {$0}
    
    static let utilityOperations: [Operation] = [
        
        // Utilities
        .binary(.evaluateAt, Node.self, Equation.self) {(n, eq) in
            let v = try Assert.cast(eq.lhs, to: Variable.self)
            Scope.save()
            defer {
                Scope.restore()
            }

            Variable.define(v.name, eq.rhs)
            let simplified = try n.simplify()
            
            if simplified.contains(where: {$0 === v}, depth: Int.max) {
                if simplified === n {
                    return nil
                }
                return Function(.evaluateAt, [simplified, eq])
            }
            
            return simplified
        },
        .binary(.evaluateAt, Node.self, List.self) {(n, list) in
            Scope.save()
            defer {
                Scope.restore()
            }
            let definitions = try Assert.specialize(list: list, as: Equation.self)
            try definitions.forEach {
                let v = try Assert.cast($0.lhs, to: Variable.self)
                Variable.define(v.name, $0.rhs)
            }

            let simplified = try n.simplify()
            var unresolved = [Equation]()
            for eq in definitions {
                if simplified.contains(where: {$0 === eq.lhs}, depth: Int.max) {
                    unresolved.append(eq)
                }
            }
            
            if unresolved.count == 1 {
                return Function(.evaluateAt, [simplified, unresolved[0]])
            } else if unresolved.count > 1 {
                if simplified === n {
                    return nil
                }
                return Function(.evaluateAt, [simplified, List(unresolved)])
            }
            
            return simplified
        },
        .binary(.repeat, [.any, .any]) {(lhs, rhs) in
            let n = try Assert.cast(rhs.simplify(), to: Int.self)
            var elements = [Node](repeating: lhs, count: n)
            return List(elements)
        },
        .init(.copy, [.any, .int]) {
            Function(.repeat, $0)
        },
        
        // Compilation & execution
        .binary(.run, KString.self, KString.self) {(flag, filePath) in
            switch flag.string {
            case "-c":
                try Program.compileAndRun(
                    filePath.string,
                    with: Program.Configuration(
                        scope: .useCurrent,
                        retentionPolicy: .restore
                    )
                )
            case "-v":
                try Program.compileAndRun(filePath.string)
            default:
                throw ExecutionError.general(errMsg: "invalid configuration \(flag.string)")
            }
            return KString("done")
        },
        .unary(.run, KString.self) {
            try Program.compileAndRun($0.string)
            return KString("done")
        },
        .unary(.compile, KString.self) {
            Final(node: try Compiler.compile($0.string))
        },
        .unary(.eval, [.any]) {
            try $0.simplify()
        },
        .binary(.invoke, Variable.self, ListProtocol.self) { (v, list) in
            Function(v.name, list.elements)
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
        .unary(.log, KString.self) {
            Program.io?.log($0.string)
            return $0
        },
        .init(.getWorkingDirectory, []) {_ in
            #if os(OSX)
                return KString(Process().currentDirectoryPath)
            #else
                throw ExecutionError.general(errMsg: "unable to resolve working directory - unsupported platform")
            #endif
        },
        .init(.readLine, []) {_ in
            guard let io = Program.io else {
                throw ExecutionError.general(errMsg: "program in/out protocol not defined")
            }
            return try KString(io.readLine())
        },
        
        /// Type casting (coersion)
        /// - Todo: Implement all possible type coersions.
        .binary(.as, Node.self, DataType.self) {(node, dt) in
            switch dt {
            case .list:
                if let list = List(node) {
                    return list
                }
                throw ExecutionError.invalidCast(from: node, to: dt)
            case .vector:
                if let vec = Vector(node) {
                    return vec
                }
                throw ExecutionError.invalidCast(from: node, to: dt)
            case .matrix:
                let list = try Assert.cast(node, to: ListProtocol.self)
                return try Matrix(list)
            case .string:
                return KString(node.stringified)
            case .variable:
                let s = try Assert.cast(node, to: KString.self)
                guard let v = Variable(s.string) else {
                    let msg = "illegal variable name \(s.string)"
                    throw ExecutionError.general(errMsg: msg)
                }
                return v
            case .number:
                let s = try Assert.cast(node, to: KString.self)
                if let n = Float80(s.string) {
                    return n
                }
                throw ExecutionError.general(errMsg: "\(s.stringified) is not a valid number")
            default:
                throw ExecutionError.general(errMsg: "conversion to \(dt) is not yet supported")
            }
        },
        .binary(.is, Node.self, DataType.self) {(n, type) in
            let nodeType = try DataType.resolve(n)
            return nodeType == type
        }
    ]
}
