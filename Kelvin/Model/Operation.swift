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

class ParametricOperation {
    
    /**
     This enum is used to represent the type of the arguments.
     By giving a function a name, the number of arguments,
     and the types of arguments, we can generate a unique signature
     that is used later to find definitions.
     */
    enum ArgumentType {
        case number
        case `var`
        case bool
        case list
        case any
        case equation
    }

    
    /**
     Pre-defined operations with signatures that are resolved and assigned
     to function definitions during compilation.
     */
    static var registered: [ParametricOperation] = [
        .init("and", [.bool, .bool]) {nodes in
            return nodes.map{$0 as! Bool}
                .reduce(true){$0 && $1}
        },
        .init("or", [.bool, .bool]) {nodes in
            return nodes.map{$0 as! Bool}
                .reduce(false){$0 || $1}
        },
        .init("sum", [.list]) {nodes in
            return Function("+", (nodes[0] as! List).elements)
        },
        .init("define",[.equation], useCmdSyntax: true) {nodes in
            // TODO: Implement
            return nil
        }
    ]
    
    let def: Definition
    let name: String
    let signature: [ArgumentType]
    let useCmdSyntax: Bool
    
    init(_ name: String, _ signature: [ArgumentType], useCmdSyntax: Bool = false, definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.signature = signature
        self.useCmdSyntax = useCmdSyntax
    }
    
    /// Register the parametric operation.
    static func register(_ parOp: ParametricOperation) {
        registered.append(parOp)
    }
    
    /**
     Resolves the corresponding parametric operation based on the name and provided arguments.
     
     - Parameter name: The name of the operation
     - Parameter args: The arguments supplied to the operation
     - Returns: The parametric operation with matching signature, if found.
     */
    static func resolve(_ name: String, args: [Node]) -> ParametricOperation? {
        let candidates = registered.filter{$0.name == name}
        for cand in candidates {
            if cand.signature.count != args.count {
                continue
            }
            for i in 0..<cand.signature.count {
                let argType = cand.signature[i]
                let arg = args[i]
                switch argType {
                case .any: return cand
                case .var where arg is Variable: return cand
                case .bool where arg is Bool: return cand
                case .list where arg is List || (arg as? Function)?.name == "list": return cand
                case .number where arg is Double || arg is Int: return cand
                default: break
                }
            }
            return cand
        }
        return nil
    }
}
