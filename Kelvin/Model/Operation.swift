//
//  Operator.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/9/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public class Operation: Equatable {
    
    /**
     This enum is used to represent the type of the arguments.
     By giving a function a name, the number of arguments,
     and the types of arguments, we can generate a unique signature
     that is used later to find definitions.
     */
    enum ArgumentType: Int, Equatable {
        case number = 0
        case `var` = 1
        case `func` = 2
        case bool = 3
        case list = 4
        case equation = 5
        case any = 100
        case numbers = 1000
        case universal = 10000 // Takes in any # of args.
    }
    
    /**
     Pre-defined operations with signatures that are resolved and assigned
     to function definitions during compilation.
     */
    static var registered: [Operation] = [
        
        // Basic binary arithmetic
        .init("+", [.numbers], syntax:
        .init(.infix, priority: .addition, operator: "+")) {bin($0, +)},
        .init("-", [.numbers], syntax:
        .init(.infix, priority: .addition, operator: "-")) {bin($0, -)},
        .init("*", [.numbers], syntax:
        .init(.infix, priority: .product, operator: "*")) {bin($0, *)},
        .init("/", [.numbers], syntax:
        .init(.infix, priority: .product, operator: "/")) {bin($0, /)},
        .init("mod", [.numbers], syntax:
        .init(.infix, priority: .product, operator: "%")) {bin($0, %)},
        .init("^", [.numbers], syntax:
        .init(.infix, priority: .exponent, operator: "^")) {bin($0, pow)},
        
        // Basic unary transcendental functions
        .init("log", [.number]) {u($0, log10)},
        .init("log2", [.number]) {u($0, log2)},
        .init("ln", [.number]) {u($0, log)},
        .init("cos", [.number]) {u($0, cos)},
        .init("sin", [.number]) {u($0, sin)},
        .init("tan", [.number]) {u($0, tan)},
        .init("int", [.number]) {u($0, floor)},
        .init("round", [.number]) {u($0, round)},
        .init("negate", [.number]) {u($0, -)},
        .init("sqrt", [.number]) {u($0, sqrt)},
        
        // Postfix operations
        .init("degrees", [.any], syntax:
        .init(.postfix, priority: .exponent, operator: "°")) {
            return Function("*", [Function("/", [$0[0], 180]), try! Variable("pi")]).format()
        },
        .init("factorial", [.number], syntax:
        .init(.postfix, priority: .exponent, operator: "!")) {
            if let i = Int(exactly: $0[0].evaluated!.doubleValue) {
                return factorial(Double(i))
            }
            return "can only perform factorial on an integer"
        },
        .init("pct", [.any], syntax:
        .init(.postfix, priority: .exponent)) {
            return Function("/", [$0[0], 100])
        },
        
        // Equality, inequality, and equations
        .init("=", [.any, .any], syntax:
        .init(.infix, priority: .equation, operator: "=")) {
            return Equation(lhs: $0[0], rhs: $0[1])
        },
        .init("<", [.any, .any], syntax:
        .init(.infix, priority: .equality, operator: "<")) {
            return Equation(lhs: $0[0], rhs: $0[1], mode: .lessThan)
        },
        .init(">", [.any, .any], syntax:
        .init(.infix, priority: .equality, operator: ">")) {
            return Equation(lhs: $0[0], rhs: $0[1], mode: .greaterThan)
        },
        .init(">=", [.any, .any], syntax:
        .init(.infix, priority: .equality, shorthand: ">=", operator: "≥")) {
            return Equation(lhs: $0[0], rhs: $0[1], mode: .greaterThanOrEquals)
        },
        .init("<=", [.any, .any], syntax:
        .init(.infix, priority: .equality, shorthand: "<=", operator: "≤")) {
            return Equation(lhs: $0[0], rhs: $0[1], mode: .lessThanOrEquals)
        },
        .init("equals", [.any, .any], syntax:
        .init(.infix, priority: .equality, shorthand: "==")) {nodes in
            return nodes[0] === nodes[1]
        },
        
        // Boolean logic and, or
        .init("and", [.bool, .bool], syntax:
        .init(.infix, priority: .and, shorthand: "&&")) {nodes in
            return nodes.map{$0 as! Bool}
                .reduce(true){$0 && $1}
        },
        .init("or", [.bool, .bool], syntax:
        .init(.infix, priority: .or, shorthand: "||")) {nodes in
            return nodes.map{$0 as! Bool}
                .reduce(false){$0 || $1}
        },
        
        // Variable/function definition and deletion
        .init("define", [.equation], simplifiesArgs: false, syntax:
        .init(.prefix, priority: .definition, shorthand: ":=")) {nodes in
            if let err = (nodes[0] as? Equation)?.define() {
                return err
            }
            return "done"
        },
        .init("define", [.any, .any], simplifiesArgs: false, syntax:
        .init(.prefix)) {nodes in
            return Function("define", [Equation(lhs: nodes[0], rhs: nodes[1])])
        },
        .init("del", [.var], syntax:
        .init(.prefix)) {nodes in
            if let v = nodes[0] as? Variable {
                Variable.delete(v.name)
                Operation.remove(v.name)
                return "deleted '\(v.name)'"
            }
            return nil
        },
        
        // Summation
        .init("sum", [.list]) {nodes in
            return Function("+", (nodes[0] as! List).elements)
        },
        .init("sum", [.universal]) {nodes in
            return Function("+", nodes)
        },
        
        // Random number generation
        .init("random", []) {nodes in
            return Double.random(in: 0...1)
        },
        .init("random", [.number, .number]) {nodes in
            let lb = nodes[0].evaluated!.doubleValue
            let ub = nodes[1].evaluated!.doubleValue
            return Double.random(in: lb...ub)
        },
        
        // List related operations
        .init("list", [.universal]) {List($0)},
        .init("get", [.list, .number], syntax:
        .init(.infix)) {nodes in
            let list = nodes[0] as! List
            let idx = Int(nodes[1].evaluated!.doubleValue)
            if idx >= list.elements.count {
                return "error: index out of bounds"
            } else {
                return list[idx]
            }
        },
        .init("size", [.list], syntax: .init(.prefix)) {
            return ($0[0] as! List).elements.count
        },
        .init("map", [.list, .any], syntax:
        .init(.infix, priority: .execution, operator: "|")) {nodes in
            let list = nodes[0] as! List
            let updated = list.elements.map {element in
                nodes[1].replacing(by: {_ in element}) {
                    ($0 as? Variable)?.name == "$"
                }
            }
            return List(updated)
        },
        
        // Average
        .init("avg", [.list]) {nodes in
            let l = (nodes[0] as! List).elements
            return Function("/", [Function("+", l), l.count])
                .format()
        },
        .init("avg", [.universal]) {nodes in
            return Function("/", [Function("+", nodes), nodes.count])
                .format()
        },

        // Consecutive execution, feed forward, flow control
        .init("exec", [.universal], simplifiesArgs: false, syntax:
        .init(.prefix, shorthand: ";")) {nodes in
            return nodes.map{$0.simplify()}.last
        },
        .init("feed", [.any, .any], simplifiesArgs: false, syntax:
        .init(.infix, shorthand: ">>")) {nodes in
            let simplified = nodes[0].simplify()
            return nodes.last!.replacing(by: {_ in simplified}) {
                ($0 as? Variable)?.name == "$"
            }
        },
        .init("repeat", [.any, .number], simplifiesArgs: false, syntax:
        .init(.infix, priority: .repeat)) {nodes in
            let times = Int(nodes[1].evaluated!.doubleValue)
            var elements = [Node]()
            (0..<times).forEach{_ in elements.append(nodes[0])}
            return List(elements)
        },
    ]
    
    let def: Definition
    let name: String
    let signature: [ArgumentType]
    let syntax: Syntax?
    var simplifiesArgs: Bool
    
    /// A value that represents the scope of the signature
    /// The larger the scope, the more universally applicable the function.
    var scope: Int {
        return signature.reduce(0) {$0 + $1.rawValue}
    }
    
    init(_ name: String, _ signature: [ArgumentType], simplifiesArgs: Bool = true, syntax: Syntax? = nil, definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.signature = signature
        self.syntax = syntax
        self.simplifiesArgs = simplifiesArgs
    }
    
    /// Register the parametric operation.
    static func register(_ parOp: Operation) {
        registered.append(parOp)
    }
    
    /**
     Remove a parametric operation from registration.
     
     - Parameters:
     - name: The name of the operation to be removed.
     - signature: The signature of the operation to be removed.
     */
    static func remove(_ name: String, _ signature: [ArgumentType]) {
        let parOp = Operation(name, signature) {_ in nil}
        registered.removeAll{$0 == parOp}
    }
    
    /// Remove the parametric operations with the given name.
    /// - Parameter name: The name of the operations to be removed.
    static func remove(_ name: String) {
        registered.removeAll{$0.name == name}
    }
    
    /**
     Resolves the corresponding parametric operation based on the name and provided arguments.
     
     - Parameter name: The name of the operation
     - Parameter args: The arguments supplied to the operation
     - Returns: The parametric operation with matching signature, if found.
     */
    public static func resolve(_ name: String, args: [Node]) -> Operation? {
        let candidates = registered.filter{$0.name == name}
            // Operations with the smaller scope should be prioritized.
            .sorted{$0.scope < $1.scope}
        
        candLoop: for cand in candidates {
            var signature = cand.signature
            
            // Deal w/ function signature types that allow any # of args.
            if let first = signature.first {
                switch first {
                case .universal:
                    signature = [ArgumentType](repeating: .any, count: args.count)
                case .numbers:
                    signature = [ArgumentType](repeating: .number, count: args.count)
                default: break
                }
            }
            
            // Bail out if # of parameters does not match # of args.
            if signature.count != args.count {
                continue
            }
            
            // Make sure that each parameter is the required type
            for i in 0..<signature.count {
                let argType = signature[i]
                let arg = args[i]
                switch argType {
                case .any:
                    continue
                case .var where !(arg is Variable):
                    fallthrough
                case .bool where !(arg is Bool):
                    fallthrough
                case .list where !(arg is List):
                    fallthrough
                case .number where !(arg is Double || arg is Int):
                    fallthrough
                case .equation where !(arg is Equation):
                    fallthrough
                case .func where !(arg is Function):
                    continue candLoop
                default: continue
                }
            }
            return cand
        }
        
        return nil
    }
    
    /**
     Find the syntax for the operation w/ the speficied name.
     The first operation that has syntax requirement w/ the given name is returned.
     
     - Parameter name: The name of the operation
     - Returns: The syntax of the operation w/ the given name. 
     */
    public static func getSyntax(for name: String) -> Syntax? {
        return registered.filter{$0.name == name && $0.syntax != nil}
            .map{$0.syntax!}.first
    }
    
    /**
     Two parametric operations are equal to each other if they have the same name
     and the same signature
     */
    public static func == (lhs: Operation, rhs: Operation) -> Bool {
        return lhs.name == rhs.name && lhs.signature == rhs.signature
    }
}

public enum Priority: Int, Comparable {
    case execution = 1  // ;, >>
    case definition     // :=
    case `repeat`       // repeat
    case equation       // =
    case or             // ||
    case and            // &&
    case equality       // ==, <, >, <=, >=
    case addition       // +,-
    case product        // *,/
    case exponent       // ^
    
    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Numerical unary operation
typealias NUnary = (Double) -> Double

/// Numerical binary operation
typealias NBinary = (Double, Double) -> Double

fileprivate func bin(_ nodes: [Node], _ binary: NBinary) -> Double {
    return nodes.map{$0.evaluated?.doubleValue ?? .nan}
        .reduce(nil) {$0 == nil ? $1 : binary($0!, $1)}!
}

fileprivate func u(_ nodes: [Node], _ unary: NUnary) -> Double {
    return unary(nodes[0].evaluated?.doubleValue ?? .nan)
}

fileprivate func log10(_ a: Double) -> Double {
    return log(a) / log(10)
}

fileprivate func %(_ a: Double, _ b: Double) -> Double {
    return a.truncatingRemainder(dividingBy: b)
}

/// A very concise definition of factorial.
fileprivate func factorial(_ n: Double) -> Double {
    return n == 0 ? 1 : n * factorial(n - 1)
}

/**
 This defines the syntax that the operation uses.
 For the function with signature "define(f(x)=x^2)",
 the prefix syntax is "define f(x)=x^2".
 
 The infix syntax, on the other hand, only applies to
 functions that take in two arguments.
 e.g. the function "and(a,b)" can be invoked with "a and b"
 */
public struct Syntax {
    
    enum Position {
        case prefix
        case infix
        case postfix
    }
    
    /// The shorthand for the operation.
    /// e.g. && for "and", and || for "or"
    var shorthand: String?
    
    /// A single character that represents the operation.
    var `operator`: Operator
    
    struct Operator: CustomStringConvertible {
        
        /// The syntactic position of the operator, either prefix, postfic, or infix
        var position: Position
        
        /// The priority of the operator
        var priority: Priority
        
        /// A single character is used to represent the operation;
        /// By doing so, the compiler can treat the operation like +,-,*,/, and so on.
        var code: Character
        
        var description: String {
            return "\(code)"
        }
        
        init(_ position: Position, _ priority: Priority, _ code: Character) {
            self.position = position
            self.priority = priority
            self.code = code
        }
    }
    
    /// A unicode scalar value that would never interfere with input
    /// In this case, the scalar value (and the ones after)
    /// does not have any unicode counterparts
    static var scalar = 60000
    
    /// A dictionary that automatically keeps track of operators.
    static var operators = [Character: Operator]()
    
    init(_ position: Position, priority: Priority = .execution, shorthand: String? = nil, operator: Character? = nil) {
        
        self.shorthand = shorthand
        
        // Assign a unique operator to the operation consisting of
        // a single character that does not exist in any language.
        let code = `operator` ?? Character(UnicodeScalar(Syntax.scalar)!)
        self.operator = Operator(position, priority, code)
        
        
        // Make sure the operator is currently undefined
        assert(Syntax.operators[code] == nil)
        
        // Register the operator
        Syntax.operators[code] = self.operator
        
        // Increment the scalar so that each operator is unique.
        Syntax.scalar += 1
    }
}
