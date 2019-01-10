//
//  Operator.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/9/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

/// Numeric binary operation
typealias NBinary = (Double, Double) throws -> Double

/**
 Binary operations such as +, -, *, /, etc.
 Supports definition of custom binary operations.
 */
class BinOperation: CustomStringConvertible {
    
    // Standard & custom binary operations
    static var registered: [String: BinOperation] = [
        "+": .init("+", .third, +),
        "-": .init("-", .third, -),
        "*": .init("*", .second, *),
        "/": .init("/", .second, /),
        "^": .init("^", .first, pow),
        ">": .init(">", .lowest){$0 > $1 ? 1 : 0},
        "<": .init("<", .lowest){$0 < $1 ? 1 : 0},
        "=": .init("=", .lowest){$0 == $1 ? 1 : 0}, // Will be replaced by compiler with an eq.
        "%": .init("%", .second){$0.truncatingRemainder(dividingBy: $1)},
        ]
    
    
    var description: String {
        return name
    }
    
    var name: String
    var bin: NBinary
    var priority: Priority
    
    private init(_ name: String, _ priority: Priority, _ bin: @escaping NBinary) {
        self.priority = priority
        self.name = name;
        self.bin = bin
    }
    
    /**
     Define a custom binary operation.
     
     - Parameter name: The name of the binary operation.
     - Parameter unary: A binary operation that takes in 2 Doubles and returns a Double.
     */
    static func define(_ name: String, priority: Priority, bin: @escaping NBinary) {
        let op = BinOperation(name, priority, bin)
        registered.updateValue(op, forKey: name)
    }
}

enum Priority: Int, Comparable {
    case highest = 0
    case first = 1
    case second = 2
    case third = 3
    case lowest = 10
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Numeric unary operation
typealias NUnary = (Double) throws -> Double

class UnaryOperation {
    
    /// Registered unary operations
    static var registered: [String: NUnary] = [
        "log": log10,
        "log2": log2,
        "ln": log,
        "int": {Double(Int($0))},
        "negate": {-$0}
    ]
    
    /**
     Define a custom unary operation.
     
     - Parameter name: The name of the unary operation.
     - Parameter unary: A unary operation taking a single Double argument
     */
    static func define(_ name: String, unary: @escaping NUnary) {
        registered.updateValue(unary, forKey: name)
    }
}

func log10(_ a: Double) -> Double {
    return log(a) / log(10)
}

class ParametricOperation: Equatable {
    
    /**
     This enum is used to represent the type of the arguments.
     By giving a function a name, the number of arguments,
     and the types of arguments, we can generate a unique signature
     that is used later to find definitions.
     */
    enum ArgumentType {
        case number
        case `var`
        case `func`
        case bool
        case list
        case any
        case equation
    }
    
    /**
     This defines the syntax that the operation uses.
     For the function with signature "define(f(x)=x^2)",
     the prefix syntax is "define f(x)=x^2".
     
     The infix syntax, on the other hand, only applies to
     functions that take in two arguments.
     e.g. the function "and(a,b)" can be invoked with "a and b"
     */
    enum Syntax: Equatable {
        case normal
        case prefix
        case infix
    }

    
    /**
     Pre-defined operations with signatures that are resolved and assigned
     to function definitions during compilation.
     */
    static var registered: [ParametricOperation] = [
        .init("and", [.bool, .bool], syntax: .infix, priority: .highest) {nodes in
            return nodes.map{$0 as! Bool}
                .reduce(true){$0 && $1}
        },
        .init("or", [.bool, .bool], syntax: .infix) {nodes in
            return nodes.map{$0 as! Bool}
                .reduce(false){$0 || $1}
        },
        .init("sum", [.list]) {nodes in
            return Function("+", (nodes[0] as! List).elements)
        },
        .init("define", [.equation], syntax: .prefix) {nodes in
            if let err = (nodes[0] as? Equation)?.define() {
                return err
            }
            return nil
        },
        .init("del", [.var], syntax: .prefix) {nodes in
            if let v = nodes[0] as? Variable {
                Variable.delete(v.name)
                ParametricOperation.remove(v.name)
            }
            return nil
        },
    ]
    
    let def: Definition
    let name: String
    let signature: [ArgumentType]
    let syntax: Syntax
    
    /// - Note: Priority only applies to infix syntax.
    let priority: Priority
    
    init(_ name: String, _ signature: [ArgumentType], syntax: Syntax = .normal, priority: Priority = .lowest, definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.signature = signature
        self.syntax = syntax
        self.priority = priority
    }
    
    /// Register the parametric operation.
    static func register(_ parOp: ParametricOperation) {
        registered.append(parOp)
    }
    
    /**
     Remove a parametric operation from registration.
     
     - Parameters:
     - name: The name of the operation to be removed.
     - signature: The signature of the operation to be removed.
     */
    static func remove(_ name: String, _ signature: [ArgumentType]) {
        let parOp = ParametricOperation(name, signature) {_ in nil}
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
    static func resolve(_ name: String, args: [Node]) -> ParametricOperation? {
        let candidates = registered.filter{$0.name == name}
        candLoop: for cand in candidates {
            if cand.signature.count != args.count {
                continue
            }
            for i in 0..<cand.signature.count {
                let argType = cand.signature[i]
                let arg = args[i]
                switch argType {
                case .any:
                    continue
                case .var where !(arg is Variable):
                    continue candLoop
                case .bool where !(arg is Bool):
                    continue candLoop
                case .list where !(arg is List):
                    continue candLoop
                case .number where !(arg is Double || arg is Int):
                    continue candLoop
                case .equation where !(arg is Equation):
                    continue candLoop
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
     Two parametric operations are equal to each other if they have the same name
     and the same signature
     */
    static func == (lhs: ParametricOperation, rhs: ParametricOperation) -> Bool {
        return lhs.name == rhs.name && lhs.signature == rhs.signature
    }
}
