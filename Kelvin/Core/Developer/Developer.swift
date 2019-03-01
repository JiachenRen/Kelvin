//
//  FlowControl.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Developer {
    public static let operations: [Operation] = [
        stringOperations,
        flowControlOperations,
        assignmentOperations,
        booleanLogicOperations,
        utilityOperations
    ].flatMap {$0}
    
    static let utilityOperations: [Operation] = [
        
        // Utilities
        .binary(.evaluateAt, [.any, .equation]) {
            let eq = $1 as! Equation
            let v = try Assert.cast(eq.lhs, to: Variable.self)
            Scope.save()
            defer {
                Scope.restore()
            }

            Variable.define(v.name, eq.rhs)
            let simplified = try $0.simplify()
            
            if simplified.contains(where: {$0 === v}, depth: Int.max) {
                if simplified === $0 {
                    return nil
                }
                return Function(.evaluateAt, [simplified, eq])
            }
            
            return simplified
        },
        .binary(.evaluateAt, [.any, .list]) {
            Scope.save()
            defer {
                Scope.restore()
            }
            let definitions = try Assert.specialize(list: $1 as! List, as: Equation.self)
            try definitions.forEach {
                let v = try Assert.cast($0.lhs, to: Variable.self)
                Variable.define(v.name, $0.rhs)
            }

            let simplified = try $0.simplify()
            var unresolved = [Equation]()
            for eq in definitions {
                if simplified.contains(where: {$0 === eq.lhs}, depth: Int.max) {
                    unresolved.append(eq)
                }
            }
            
            if unresolved.count == 1 {
                return Function(.evaluateAt, [simplified, unresolved[0]])
            } else if unresolved.count > 1 {
                if simplified === $0 {
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
        .init(.copy, [.any, .number]) {
            Function(.repeat, $0)
        },
        .init(.readLine, []) {_ in
            guard let io = Program.io else {
                throw ExecutionError.general(errMsg: "program in/out protocol not found")
            }
            return try KString(io.readLine())
        },
        
        // Debug utilities
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
            Float80(Date().timeIntervalSince1970)
        },
        .unary(.delay, [.number]) {
            Thread.sleep(forTimeInterval: Double($0≈!))
            return KString("done")
        },
        .binary(.measure, [.int, .any]) {
            let n = $0 as! Int
            let t = Date().timeIntervalSince1970
            for _ in 0..<n {
                let _ = try $1.simplify()
            }
            let avg = Float80(Date().timeIntervalSince1970 - t) / Float80(n)
            return Pair("avg(s)", avg)
        },
        .unary(.measure, [.any]) {
            let t = Date().timeIntervalSince1970
            let _ = try $0.simplify()
            return Float80(Date().timeIntervalSince1970 - t)
        },
        
        // Compilation & execution
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
        },
        .init(.getWorkingDirectory, []) {_ in
            KString(Process().currentDirectoryPath)
        },
        
        /// Type casting (coersion)
        /// - Todo: Implement all possible type coersions.
        .binary(.as, [.any, .var]) {
            let n = $1 as! Variable, c = $0
            let dt = try Assert.dataType(n.name)
            
            switch dt {
            case .list:
                if let list = List($0) {
                    return list
                }
                throw ExecutionError.invalidCast(from: c, to: dt)
            case .vector:
                if let vec = Vector($0) {
                    return vec
                }
                throw ExecutionError.invalidCast(from: c, to: dt)
            case .matrix:
                let list = try Assert.cast($0, to: ListProtocol.self)
                return try Matrix(list)
            case .string:
                return KString(c.stringified)
            case .variable:
                let s = try Assert.cast($0, to: KString.self)
                guard let v = Variable(s.string) else {
                    let msg = "illegal variable name \(s.string)"
                    throw ExecutionError.general(errMsg: msg)
                }
                return v
            case .number:
                let s = try Assert.cast($0, to: KString.self)
                if let n = Float80(s.string) {
                    return n
                }
                throw ExecutionError.general(errMsg: "\(s.stringified) is not a valid number")
            default:
                throw ExecutionError.general(errMsg: "conversion to \(dt) is not yet supported")
            }
        },
        .binary(.is, [.any, .var]) {
            let v = $1 as! Variable
            let t1 = try Assert.dataType(v.name)
            let t2 = try DataType.resolve($0)
            return t2 == t1
        }
    ]
}
