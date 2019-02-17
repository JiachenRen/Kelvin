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
            guard let v = eq.lhs as? Variable else {
                let msg = "left hand side of definition \(eq.stringified) must be a variable"
                throw ExecutionError.general(errMsg: msg)
            }
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
            let list = $1 as! List
            Scope.save()
            let definitions = try list.map {
                (n) -> Equation in
                guard let eq = n as? Equation else {
                    throw ExecutionError.unexpectedType(
                        list,
                        expected: .equation,
                        found: try .resolve(n)
                    )
                }
                return eq
            }
            
            for eq in definitions {
                guard let v = eq.lhs as? Variable else {
                    let msg = "left hand side of definition \(eq.stringified) must be a variable"
                    throw ExecutionError.general(errMsg: msg)
                }
                Variable.define(v.name, eq.rhs)
            }
            
            defer {
                Scope.restore()
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
        
        /// Type casting (coersion)
        /// - Todo: Implement all possible type coersions.
        .binary(.as, [.any, .var]) {
            let n = $1 as! Variable, c = $0
            guard let dt = DataType(rawValue: n.name) else {
                throw ExecutionError.invalidType(
                    Function(.as, [c, n]),
                    invalidTypeLiteral: n.name)
            }
            
            func bailOut(msg: String? = nil) throws {
                if let m = msg {
                    throw ExecutionError.general(errMsg: m)
                }
                throw ExecutionError.invalidCast(from: c, to: dt)
            }
            
            switch dt {
            case .list:
                if let list = List($0) {
                    return list
                }
                try bailOut()
            case .vector:
                if let vec = Vector($0) {
                    return vec
                }
                try bailOut()
            case .matrix:
                if let list = $0 as? ListProtocol {
                    return try Matrix(list)
                }
                try bailOut()
            case .string:
                return KString(c.stringified)
            case .variable:
                if let s = $0 as? KString  {
                    return try Variable(s.string)
                }
                try bailOut()
            default:
                break
            }
            
            return nil
        },
        .binary(.is, [.any, .var]) {
            let v = $1 as! Variable
            guard let t1 = DataType(rawValue: v.name) else {
                throw ExecutionError.invalidType(Function(.is, [$0, $1]), invalidTypeLiteral: v.name)
            }
            
            let t2 = try DataType.resolve($0)
            return t2 == t1
        }
    ]
}
