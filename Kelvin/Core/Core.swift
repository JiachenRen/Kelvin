//
//  Core.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Core contains the most basic functions of Kelvin Algebra System.
public class Core {
    
    public static var date: TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    /// Finds the greatest common divisor of `a` and   `b`.
    public static func gcd(_ a: Int, _ b: Int) -> Int {
        let a = abs(a)
        let b = abs(b)
        if a == 0 || b == 0 {
            return a == 0 ? b : a
        } else if a > b {
            return gcd(b, a % b)
        }
        return gcd(a, b % a)
    }

    /// Finds the least common multiple of `a` and `b`.
    public static func lcm(_ a: Int, _ b: Int) -> Int {
        let g = gcd(a, b)
        return g == 0 ? 0 : abs(a * b / g)
    }

    /// Finds the prime factorization of `n`.
    /// e.g. `primeFactors(10)` returns `[2,2,5,5]`
    /// - Returns: An array of prime factorization of `n`.
    public static func primeFactors(of n: Int) -> [Int] {
        var n = n
        var factors = [Int]()
        
        if n == 0 || n == 1 {
            factors.append(n)
            return factors
        } else if n < 0 {
            factors.append(-1)
            n /= -1
        }
        
        // Find the number of 2s that divide n
        while n % 2 == 0 {
            factors.append(2)
            n /= 2
        }
        
        // n must be odd at this point.
        var i = 3
        while i <= Int(sqrt(Double(n))) {
            
            // While i divides n, add i and divide n
            while (n % i == 0) {
                factors.append(i)
                n /= i;
            }
            
            i += 2
        }
        
        
        // This condition is to handle the case whien
        // n is a prime number greater than 2
        if (n > 2) {
            factors.append(n)
        }
        return factors
    }

    /// Rounds `x` to specified `dp` decimal places.
    public static func _round(_ x: Float80, toDecimalPlaces dp: Int) -> Float80 {
        let p: Float80 = pow(Float80(10.0), Float80(dp))
        return round(p * x) / p
    }
    
    /// Computes the raw result of binary operation involving two floating points.
    /// - Parameters:
    ///     - lhs: Left hand side of the binary operation; must be `NaN`
    ///     - rhs: Right hand side of the binary operation; must be `NaN`
    ///     - binary: A binary operation involving two floating points. E.g. `+, -, *, /`
    /// - Todo: Implement mode exact vs approximate.
    private static func bin(_ lhs: Node, _ rhs: Node, _ binary: NBinary) -> Float80 {
        return binary(lhs≈!, rhs≈!)
    }
    
    /// Computes the raw numerical result of node using the provided unary operation.
    private static func u(_ operand: Node, _ unary: NUnary) -> Float80 {
        return unary(operand≈ ?? .nan)
    }
    
    /// Assign `bin(variable, value)` to  `variable`.
    /// - Parameters:
    ///     - variable: First operand of `bin`, must be a variable.
    ///     - value: Second operand of `bin `
    private static func assign(_ value: Node, to variable: Node, byApplying bin: Binary) throws -> Node {
        assert(variable is Variable)
        try Equation(lhs: variable, rhs: bin(variable, value)).define()
        return variable
    }
    /// Execute shell command. Errors are logged.
    /// - Parameter command: Shell command to be executed.
    /// - Returns: Std. out as string obtained by executing the shell command.
    public static func runShell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let stdPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = stdPipe
        task.standardError = errPipe
        task.launch()
        
        // If error msg is not empty, print the error msg.
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let errMsg = String(data: errData, encoding: .utf8)!
        if !errMsg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Program.shared.io?.error(errMsg)
        }
        
        let stdData = stdPipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: stdData, encoding: .utf8)!
        return output
    }
    
    /// Evaluates `node` by first injecting the provided `definition`.
    /// E.g. `node = a + b, definition: (a = 3)`, then `evaluate` returns `3 + b`.
    /// - Parameters:
    ///     - node: Node to be evaluated.
    ///     - definition: An equation whose LHS is a `Variable` and whose RHS is its definition.
    /// - Returns: Simplified `node` using the provided definition.
    public static func evaluate(_ node: Node, using definition: Equation) throws -> Node? {
        let v = try Assert.cast(definition.lhs, to: Variable.self)
        Scope.save()
        defer {
            Scope.restore()
        }
        Variable.define(v.name, definition.rhs)
        let simplified = try node.simplify()
        if simplified.contains(where: {$0 === v}, depth: Int.max) {
            if simplified === node {
                return nil
            }
            return try evaluate(simplified, using: definition)
        }
        return simplified
    }
    
    /// Evaluates `node` by first injecting the provided `definition`.
    /// E.g. `node = a + b, defns: [a = 3, b = 5]`, then `evaluate` returns `8`.
    /// - Parameters:
    ///     - node: Node to be evaluated.
    ///     - defns: A list of equations eacho containing `Variable` as its LHS and the respective defn of the var as RHS.
    /// - Returns: Simplified `node` using the provided definitions.
    public static func evaluate(_ node: Node, using defns: [Equation]) throws -> Node? {
        Scope.save()
        defer {
            Scope.restore()
        }
        try defns.forEach {
            let v = try Assert.cast($0.lhs, to: Variable.self)
            Variable.define(v.name, $0.rhs)
        }
        let simplified = try node.simplify()
        var unresolved = [Equation]()
        for eq in defns {
            if simplified.contains(where: {$0 === eq.lhs}, depth: Int.max) {
                unresolved.append(eq)
            }
        }
        if unresolved.count == 1 {
            return try evaluate(simplified, using: unresolved[0])
        } else if unresolved.count > 1 {
            if simplified === node {
                return nil
            }
            return try evaluate(simplified, using: unresolved)
        }
        return simplified
    }
    
    static let exports: [Operation] = [
        
        // Relational operators
        .binary(.equates, [.any, .any]) {
            Equation(lhs: $0, rhs: $1)
        },
        .binary(.lessThan, [.any, .any]) {
            Equation(lhs: $0, rhs: $1, mode: .lessThan)
        },
        .binary(.greaterThan, [.any, .any]) {
            Equation(lhs: $0, rhs: $1, mode: .greaterThan)
        },
        .binary(.greaterThanOrEquals, [.any, .any]) {
            Equation(lhs: $0, rhs: $1, mode: .greaterThanOrEquals)
        },
        .binary(.lessThanOrEquals, [.any, .any]) {
            Equation(lhs: $0, rhs: $1, mode: .lessThanOrEquals)
        },
        .binary(.equals, [.any, .any]) {
            $0 === $1
        },
        .binary(.notEquals, [.any, .any]) {
            $0 !== $1
        },
        
        // Number utils
        .binary(.greatestCommonDivisor, Int.self, Int.self) {
            gcd($0, $1)
        },
        .binary(.leastCommonMultiple, Int.self, Int.self) {
            lcm($0, $1)
        },
        .unary(.factorize, Int.self) {
            List(primeFactors(of: $0))
        },
        .unary(.degrees, [.any]) {
            $0 / 180 * ("pi"&)
        },
        .unary(.percent, [.any]) {
            $0 / 100
        },
        .binary(.round, Value.self, Int.self) {
            _round($0.float80, toDecimalPlaces: $1)
        },
        
        // System utils
        .unary(.complexity, [.any]) {
            $0.complexity
        },
        .init(.exit, []) { _ in
            exit(0)
        },
        .init(.date, []) { _ in
            KString("\(Date())")
        },
        .init(.time, []) { _ in
            Float80(date)
        },
        .unary(.delay, Value.self) {
            Thread.sleep(forTimeInterval: Double($0.float80))
            return KString("done")
        },
        .binary(.measure, Int.self, Node.self) {(i, n) in
            let t = date
            for _ in 0..<i {
                let _ = try n.simplify()
            }
            let avg = Float80(date - t) / Float80(i)
            return Pair("avg(s)", avg)
        },
        .unary(.measure, [.any]) {
            let t = date
            let _ = try $0.simplify()
            return Float80(date - t)
        },
        .binary(.repeat, [.any, .any]) {(lhs, rhs) in
            let n = try Assert.cast(rhs.simplify(), to: Int.self)
            var elements = [Node](repeating: lhs, count: n)
            return List(elements)
        },
        .init(.copy, [.any, .int]) {
            Function(.repeat, $0)
        },
        
        // Manage variable/function definitions
        .noArg(.listVariables) {
            List(Variable.definitions.keys.compactMap { Variable($0) }).finalize()
        },
        .noArg(.clearVariables) {
            Variable.restoreDefault()
            return KVoid()
        },
        .noArg(.listFunctions) {
            List(Operation.userDefined.map {KString($0.description)})
        },
        .noArg(.clearFunctions) {
            Operation.restoreDefault()
            return KVoid()
        },
        
        // Elementary binary / unary operations
        // On raw values only
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
        
        // Basic binary arithmetics
        .binary(.add, [.number, .number]) {
            bin($0, $1, +)
        },
        .binary(.sub, [.number, .number]) {
            bin($0, $1, -)
        },
        .binary(.mult, [.number, .number]) {
            bin($0, $1, *)
        },
        .binary(.div, [.number, .number]) {
            bin($0, $1, /)
        },
        .binary(.mod, [.number, .number]) {
            bin($0, $1) {
                $0.truncatingRemainder(dividingBy: $1)
            }
        },
        .binary(.exp, [.number, .number]) {
            bin($0, $1, pow)
        },
        
        // Basic unary transcendental operations
        .unary(.log, [.number]) {
            u($0, log10)
        },
        .unary(.log2, [.number]) {
            u($0, log2)
        },
        .unary(.ln, [.number]) {
            u($0, log)
        },
        .unary(.cos, [.number]) {
            u($0, cos)
        },
        .unary(.acos, [.number]) {
            u($0, acos)
        },
        .unary(.cosh, [.number]) {
            u($0, cosh)
        },
        .unary(.sin, [.number]) {
            u($0, sin)
        },
        .unary(.asin, [.number]) {
            u($0, asin)
        },
        .unary(.sinh, [.number]) {
            u($0, sinh)
        },
        .unary(.tan, [.number]) {
            u($0, tan)
        },
        .unary(.tan, [.any]) {
            sin($0) / cos($0)
        },
        .unary(.atan, [.number]) {
            u($0, atan)
        },
        .unary(.tanh, [.number]) {
            u($0, tanh)
        },
        .unary(.sec, [.any]) {
            1 / cos($0)
        },
        .unary(.csc, [.any]) {
            1 / sin($0)
        },
        .unary(.cot, [.any]) {
            1 / tan($0)
        },
        .unary(.abs, [.number]) {
            u($0, abs)
        },
        .unary(.int, [.number]) {
            u($0, floor)
        },
        .unary(.round, [.number]) {
            u($0, round)
        },
        .unary(.negate, [.number]) {
            u($0, -)
        },
        .unary(.sqrt, [.number]) {
            u($0, sqrt)
        },
        .unary(.sign, Value.self) {
            let n = $0.float80
            return n == 0 ? Float80.nan : n > 0 ? 1 : -1
        },
        
        // Basic IO
        .unary(.print, [.any]) {
            Program.shared.io?.print($0)
            return $0
        },
        .unary(.println, [.any]) {
            Program.shared.io?.println($0)
            return $0
        },
        .unary(.printMat, Matrix.self) {
            Program.shared.io?.println(KString($0.minimal))
            return $0
        },
        .unary(.log, KString.self) {
            Program.shared.io?.log($0.string)
            return $0
        },
        .noArg(.readLine) {
            guard let io = Program.shared.io else {
                throw ExecutionError.general(errMsg: "program in/out protocol not defined")
            }
            return try KString(io.readLine())
        },
        
        // Variable/function definition
        /// - Todo: report what has been done using Program.io?.log
        // def a = 3
        // def f(x) = x^2
        .unary(.define, Equation.self) {
            try $0.define()
            return KVoid()
        },
        // def f(x) { return x + g(x) }
        .unary(.define, Function.self) {
            var fun = $0
            var closure = try Assert.cast(fun.elements.last, to: Closure.self)
            fun.elements.removeLast()
            closure.capturesReturn = true
            try fun.implement(using: closure)
            return KVoid()
        },
        // a := 3
        .binary(.assign, [.any, .any]) {
            return Function(.define, [Equation(lhs: $0, rhs: $1)])
        },
        
        // Delete variable/function
        .unary(.del, Variable.self) {v in
            Variable.delete(v.name)
            Operation.remove(v.name)
            return KVoid()
        },
        
        // C like assignment shorthand
        // ++
        .unary(.increment, [.var]) {
            $0 +== 1
        },
        // --
        .unary(.decrement, [.var]) {
            $0 -== 1
        },
        // +=
        .binary(.mutatingAdd, Variable.self, Node.self) {
            try assign($1, to: $0, byApplying: +)
        },
        // -=
        .binary(.mutatingSub, Variable.self, Node.self) {
            try assign($1, to: $0, byApplying: -)
        },
        // *=
        .binary(.mutatingMult, Variable.self, Node.self) {
            try assign($1, to: $0, byApplying: *)
        },
        // /=
        .binary(.mutatingDiv, Variable.self, Node.self) {
            try assign($1, to: $0, byApplying: /)
        },
        // &=
        .binary(.mutatingConcat, Variable.self, Node.self) {(v, n) in
            try Equation(lhs: v, rhs: Function(.concat, [v, n]))
                .define()
            return v
        },
        
        // Substitution / Injection
        // x + a + b << x = 3 << a = 2
        .binary(.evaluateAt, Node.self, Equation.self) {
            try evaluate($0, using: $1)
        },
        // a + b + c << {a = 3, c = 2}
        .binary(.evaluateAt, Node.self, List.self) {
            try evaluate($0, using: Assert.specialize(list: $1, as: Equation.self))
        },
        // f(x, y) = x ^ 2 + y; f <<< {x, y}
        .binary(.invoke, Variable.self, List.self) { (v, list) in
            Function(v.name, list.elements)
        },
        
        // Runtime environment
        /// - Todo: Add the ability to choose scope retention policy.
        .unary(.run, KString.self) {
            let prg = Program(io: Program.shared.io)
            try prg.compileAndRun(fileAt: $0.string)
            return KVoid()
        },
        .unary(.import, KString.self) {
            try Program.import(fileAt: $0.string)
            Program.shared.io?.log("imported \($0.string)")
            return KVoid()
        },
        .unary(.compile, KString.self) {
            try Compiler.shared.compile($0.string).finalize()
        },
        .unary(.eval, [.any]) {
            try $0.simplify()
        },
        // Execute shell command
        .unary(.runShell, KString.self) { cmd in
            return KString(runShell(cmd.string))
        },
        
        // Type system
        .binary(.as, Node.self, KType.self) {
            try KType.convert($0, to: $1)
        },
        .binary(.is, Node.self, KType.self) {(n, type) in
            Swift.type(of: n).kType == type
        }
    ]
}
