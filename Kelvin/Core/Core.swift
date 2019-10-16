//
//  Core.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

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
    private static func bin(_ lhs: Node, _ rhs: Node, _ binary: NBinary) -> Node? {
        guard let l = lhs.evaluated, let r = rhs.evaluated else { return nil }
        let result = binary(l.float80, r.float80)
        switch Mode.shared.rounding {
        case .approximate,
             .auto where lhs is Float80 || rhs is Float80:
            return result
        default:
            return exactResult(from: result)
        }
    }
    
    /// Converts the provided approximate value to an exact value, if possible.
    /// - Returns: The exact form of the approximate result, if it exists; if not, return `nil`.
    private static func exactResult(from result: Float80) -> Exact? {
        if let i = Int(exactly: result) {
            return i
        } else if let f = Fraction(exactly: result) {
            return f
        }
        return nil
    }
    
    /// Computes the raw numerical result of node using the provided unary operation.
    private static func u(_ operand: Node, _ unary: NUnary) -> Node? {
        guard let val = operand.evaluated else { return nil }
        let result = unary(val.float80)
        switch Mode.shared.rounding {
        case .exact,
             .auto where !(operand is Float80):
            return exactResult(from: result)
        default:
            return result
        }
    }
    
    /// Assign `bin(variable, number)` to  `variable`.
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
        .binary(.equates, [.node, .node]) {
            Equation(lhs: $0, rhs: $1)
        },
        .binary(.lessThan, [.node, .node]) {
            Equation(lhs: $0, rhs: $1, mode: .lessThan)
        },
        .binary(.greaterThan, [.node, .node]) {
            Equation(lhs: $0, rhs: $1, mode: .greaterThan)
        },
        .binary(.greaterThanOrEquals, [.node, .node]) {
            Equation(lhs: $0, rhs: $1, mode: .greaterThanOrEquals)
        },
        .binary(.lessThanOrEquals, [.node, .node]) {
            Equation(lhs: $0, rhs: $1, mode: .lessThanOrEquals)
        },
        .binary(.equals, [.node, .node]) {
            $0 === $1
        },
        .binary(.notEquals, [.node, .node]) {
            $0 !== $1
        },
        
        // Number theory
        .binary(.greatestCommonDivisor, Integer.self, Integer.self) {
            $0.bigInt.greatestCommonDivisor(with: $1.bigInt)
        },
        .binary(.leastCommonMultiple, Integer.self, Integer.self) {
            $0.bigInt.leastCommonMultiple(with: $1.bigInt)
        },
        .unary(.factorize, Integer.self) {
            (n: Integer) throws -> Node? in
            List(n.bigInt.primeFactors().map {
                [BigInt](repeating: $0.factor, count: Int($0.multiplicity))
            }.flatMap { $0 })
        },
        .unary(.factors, Integer.self) {
            (n: Integer) throws -> Node? in
            let primeFactors = n.bigInt.primeFactors()
            return List([
                List(primeFactors.map { $0.factor }),
                List(primeFactors.map { $0.multiplicity })
            ])
        },
        .unary(.isPrime, Integer.self) {
            $0.bigInt.isPrime()
        },
        .unary(.degrees, [.node]) {
            $0 / 180 * (Constant(.pi))
        },
        .unary(.percent, [.node]) {
            $0 / 100
        },
        .binary(.round, Number.self, Int.self) {
            _round($0.float80, toDecimalPlaces: $1)
        },
        
        // System utils
        .unary(.complexity, [.node]) {
            $0.complexity
        },
        .init(.exit, []) { _ in
            exit(0)
        },
        .init(.date, []) { _ in
            String("\(Date())")
        },
        .init(.time, []) { _ in
            Float80(date)
        },
        .unary(.delay, Number.self) {
            Thread.sleep(forTimeInterval: Double($0.float80))
            return String("done")
        },
        .binary(.measure, Int.self, Node.self) {(i, n) in
            let t = date
            for _ in 0..<i {
                let _ = try n.simplify()
            }
            let avg = Float80(date - t) / Float80(i)
            return Pair("avg(s)", avg)
        },
        .unary(.measure, [.node]) {
            let t = date
            let _ = try $0.simplify()
            return Float80(date - t)
        },
        .binary(.repeat, [.node, .node]) {(lhs, rhs) in
            let n = try Assert.cast(rhs.simplify(), to: Int.self)
            var elements = [Node](repeating: lhs, count: n)
            return List(elements)
        },
        .init(.copy, [.node, .int]) {
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
            List(Operation.userDefined.map {String($0.description)})
        },
        .noArg(.clearFunctions) {
            Operation.restoreDefault()
            return KVoid()
        },
        
        // Elementary binary / unary operations
        // On raw values only
        // Elementary boolean operator set
        .init(.and, [.init(.bool, multiplicity: .any)]) {
            for n in $0 {
                if !(n as! Bool) {
                    return false
                }
            }
            return true
        },
        .init(.or, [.init(.bool, multiplicity: .any)]) {
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
        .binary(.xor, [.node, .node]) {
            (!!$0 &&& $1) ||| ($0 &&& !!$1)
        },
        .binary(.nor, [.node, .node]) {
            !!($0 ||| $1)
        },
        .binary(.nand, [.node, .node]) {
            !!($0 &&& $1)
        },
        
        // Basic binary arithmetics
        .binary(.add, Node.self, Node.self) {
            bin($0, $1, +)
        },
        .binary(.sub, Node.self, Node.self) {
            bin($0, $1, -)
        },
        .binary(.mult, Node.self, Node.self) {
            bin($0, $1, *)
        },
        .binary(.div, Node.self, Node.self) {
            bin($0, $1, /)
        },
        .binary(.mod, Node.self, Node.self) {
            bin($0, $1) {
                $0.truncatingRemainder(dividingBy: $1)
            }
        },
        .binary(.power, Node.self, Node.self) {
            bin($0, $1, pow)
        },
        
        // Basic unary transcendental operations
        .unary(.log, Node.self) {
            u($0, log10)
        },
        .unary(.log2, Node.self) {
            u($0, log2)
        },
        .unary(.ln, Node.self) {
            u($0, log)
        },
        .unary(.cos, Node.self) {
            u($0, cos)
        },
        .unary(.acos, Node.self) {
            u($0, acos)
        },
        .unary(.cosh, Node.self) {
            u($0, cosh)
        },
        .unary(.sin, Node.self) {
            u($0, sin)
        },
        .unary(.asin, Node.self) {
            u($0, asin)
        },
        .unary(.sinh, Node.self) {
            u($0, sinh)
        },
        .unary(.tan, Node.self) {
            u($0, tan)
        },
        .unary(.atan, Node.self) {
            u($0, atan)
        },
        .unary(.tanh, Node.self) {
            u($0, tanh)
        },
        .unary(.abs, Node.self) {
            u($0, abs)
        },
        .unary(.negate, Node.self) {
            u($0, -)
        },
        .unary(.sqrt, Node.self) {
            u($0, sqrt)
        },
        
        .unary(.int, Node.self) {
            u($0, floor)
        },
        .unary(.round, Node.self) {
            u($0, round)
        },
        .unary(.sign, Node.self) {
            u($0) { $0 == 0 ? 0 : $0 > 0 ? 1 : -1 }
        },
        
        .unary(.int, Number.self) {
            u($0, floor)
        },
        .unary(.round, Number.self) {
            u($0, round)
        },
        .unary(.sign, Number.self) {
            u($0) { $0 == 0 ? 0 : $0 > 0 ? 1 : -1 }
        },
        
        .binary(.add, Exact.self, Exact.self) {
            $0.adding($1)
        },
        .binary(.sub, Exact.self, Exact.self) {
            $0.subtracting($1)
        },
        .binary(.mult, Exact.self, Exact.self) {
            $0.multiplying($1)
        },
        .binary(.div, Exact.self, Exact.self) {
            $0.dividing($1)
        },
        .binary(.power, Exact.self, Exact.self) {
            $0.power($1)
        },
        
        .unary(.negate, Exact.self) {
            $0.negate()
        },
        .unary(.abs, Exact.self) {
            $0.abs()
        },
        
        .binary(.div, Integer.self, Integer.self) {
            if Mode.shared.rounding == .approximate { return nil }
            return Fraction($0.bigInt, $1.bigInt)
        },
        .binary(.mod, Integer.self, Integer.self) {
            $0.bigInt.modulus($1.bigInt)
        },
        
        // Basic IO
        .unary(.print, [.node]) {
            Program.shared.io?.print($0)
            return $0
        },
        .unary(.println, [.node]) {
            Program.shared.io?.println($0)
            return $0
        },
        .unary(.printMat, Matrix.self) {
            Program.shared.io?.println(String($0.minimal))
            return $0
        },
        .unary(.log, String.self) {
            Program.shared.io?.log($0)
            return $0
        },
        .noArg(.readLine) {
            guard let io = Program.shared.io else {
                throw ExecutionError.general(errMsg: "program in/out protocol not defined")
            }
            return try String(io.readLine())
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
        .binary(.assign, [.node, .node]) {
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
        .unary(.increment, [.variable]) {
            $0 +== 1
        },
        // --
        .unary(.decrement, [.variable]) {
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
        .unary(.run, String.self) {
            let prg = Program(io: Program.shared.io)
            try prg.compileAndRun(fileAt: $0)
            return KVoid()
        },
        .unary(.import, String.self) {
            try Program.import(fileAt: $0)
            Program.shared.io?.log("imported \($0)")
            return KVoid()
        },
        .unary(.compile, String.self) {
            try Compiler.shared.compile($0).finalize()
        },
        .unary(.eval, [.node]) {
            try $0.simplify()
        },
        // Execute shell command
        .unary(.runShell, String.self) { cmd in
            String(runShell(cmd))
        },
        
        // Type system
        .binary(.as, Node.self, KType.self) {
            try KType.convert($0, to: $1)
        },
        .binary(.is, Node.self, KType.self) {(n, type) in
            KType.resolve(n) == type
        },
        
        // Set mode
        .binary(.setMode, String.self, String.self) {
            (category, option) in
            switch category {
            case "rounding":
                guard let r = Mode.Rounding(rawValue: option) else {
                    throw ExecutionError.invalidOption(option)
                }
                Mode.shared.rounding = r
            case "extrapolation":
                guard let e = Mode.Extrapolation(rawValue: option) else {
                    throw ExecutionError.invalidOption(option)
                }
                Mode.shared.extrapolation = e
            default:
                throw ExecutionError.invalidOption(category)
            }
            Program.shared.io?.log("\(category) set to \(option)")
            return KVoid()
        }
    ]
}
