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
class BinaryOperation: CustomStringConvertible {
    
    // Built in binary operations
    static let builtIn: [BinaryOperation] = [
        .init("+", .addition, +),
        .init("-", .addition, -),
        .init("*", .product, *),
        .init("/", .product, /),
        .init("^", .exponent, pow),
        .init(">", .equality){$0 > $1 ? 1 : 0},
        .init("<", .equality){$0 < $1 ? 1 : 0},
        .init("=", .equation){$0 == $1 ? 1 : 0}, // Will be replaced by compiler with an eq.
        .init("%", .product){$0.truncatingRemainder(dividingBy: $1)},
    ]
    
    /// Custom binary operations are added here.
    /// Built-in operations are preloaded.
    static var registered: [String: BinaryOperation] = {
        return builtIn.reduce(into: [:]){$0[$1.name] = $1}
    }()
    
    
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
        let op = BinaryOperation(name, priority, bin)
        registered.updateValue(op, forKey: name)
    }
}

enum Priority: Int, Comparable {
    case exponent = 1
    case product
    case addition
    case equality
    case and
    case or
    case equation
    case definition
    case execution
    
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
        "round": {round($0)},
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
    enum ArgumentType: Int, Equatable {
        case number = 0
        case `var` = 1
        case `func` = 2
        case bool = 3
        case list = 4
        case equation = 5
        case any = 100
        case universal = 10000 // Takes in any # of args.
    }
    
    /**
     This defines the syntax that the operation uses.
     For the function with signature "define(f(x)=x^2)",
     the prefix syntax is "define f(x)=x^2".
     
     The infix syntax, on the other hand, only applies to
     functions that take in two arguments.
     e.g. the function "and(a,b)" can be invoked with "a and b"
     */
    struct SyntacticSugar {
        
        enum Position {
            case prefix
            case infix
        }
        
        /// The syntactic position of the operation, either prefix or infix.
        var position: Position
        
        /// The priority of the operation
        var priority: Priority
        
        /// The shorthand for the operation.
        /// e.g. && for "and", and || for "or"
        var shorthand: String?
        
        /// A single character is used to represent the operation;
        /// By doing so, the compiler can treat the operation like +,-,*,/, and so on.
        var code: String
        
        /// A unicode scalar value that would never interfere with input
        /// In this case, the scalar value (and the ones after)
        /// does not have any unicode counterparts
        static var scalar = 60000
        
        init(_ position: Position, priority: Priority = .execution, shorthand: String? = nil) {
            
            self.position = position
            self.priority = priority
            self.shorthand = shorthand
            
            // Assign a unique code to the operation consisting of
            // a single character that does not exist in any language.
            code = "\(UnicodeScalar(SyntacticSugar.scalar)!)"
            
            // Ensure that a valid code is generated.
            assert(code.count == 1)
            
            // Increment the scalar so that each code is unique.
            SyntacticSugar.scalar += 1
        }
    }

    
    /**
     Pre-defined operations with signatures that are resolved and assigned
     to function definitions during compilation.
     */
    static var registered: [ParametricOperation] = [
        .init("and", [.bool, .bool], syntacticSugar:
        .init(.infix, priority: .and, shorthand: "&&")) {nodes in
            return nodes.map{$0 as! Bool}
                .reduce(true){$0 && $1}
        },
        .init("or", [.bool, .bool], syntacticSugar:
        .init(.infix, priority: .or, shorthand: "||")) {nodes in
            return nodes.map{$0 as! Bool}
                .reduce(false){$0 || $1}
        },
        .init("sum", [.list]) {nodes in
            return Function("+", (nodes[0] as! List).elements)
        },
        .init("sum", [.universal]) {nodes in
            return Function("+", nodes)
        },
        .init("define", [.equation], syntacticSugar:
        .init(.prefix, priority: .definition, shorthand: ":=")) {nodes in
            if let err = (nodes[0] as? Equation)?.define() {
                return err
            }
            return nil
        },
        .init("define", [.any, .any], syntacticSugar:
        .init(.prefix)) {nodes in
            return Function("define", [Equation(lhs: nodes[0], rhs: nodes[1])])
        },
        .init("del", [.var], syntacticSugar:
        .init(.prefix)) {nodes in
            if let v = nodes[0] as? Variable {
                Variable.delete(v.name)
                ParametricOperation.remove(v.name)
            }
            return nil
        },
        .init("random", []) {nodes in
            return Double.random(in: 0...1)
        },
        .init("random", [.number, .number]) {nodes in
            let lb = nodes[0].evaluated!.doubleValue()
            let ub = nodes[1].evaluated!.doubleValue()
            return Double.random(in: lb...ub)
        },
        .init("repeat", [.any, .number], syntacticSugar:
        .init(.infix)) {nodes in
            let times = Int(nodes[1].evaluated!.doubleValue())
            var elements = [Node]()
            (0..<times).forEach{_ in elements.append(nodes[0])}
            return List(elements)
        },
        .init("get", [.list, .number], syntacticSugar:
        .init(.infix)) {nodes in
            let list = nodes[0] as! List
            let idx = Int(nodes[1].evaluated!.doubleValue())
            if idx >= list.elements.count {
                return KelvinError(msg: "index out of bounds")
            } else {
                return list[idx]
            }
        },
        .init("size", [.list], syntacticSugar:
        .init(.prefix)) {nodes in
            return (nodes[0] as! List).elements.count
        },
        .init("avg", [.list]) {nodes in
            let l = (nodes[0] as! List).elements
            return Function("/", [Function("+", l), l.count])
                .format()
        },
        .init("avg", [.universal]) {nodes in
            return Function("/", [Function("+", nodes), nodes.count])
                .format()
        },
        .init("mod", [.number, .number], syntacticSugar:
        .init(.infix, priority: .product)) {nodes in
            return Function("%", nodes)
        },
        .init("exec", [.universal], syntacticSugar:
        .init(.prefix, shorthand: ";")) {nodes in
            // This is for consecutive execution of statements
            return nodes.last
        },
        .init("feed", [.any, .any], syntacticSugar:
        .init(.infix, shorthand: ">>")) {nodes in
            return nodes.last!.replacing(by: {_ in nodes[0]}) {
                ($0 as? Variable)?.name == "$"
            }
        },
    ]
    
    let def: Definition
    let name: String
    let signature: [ArgumentType]
    let syntacticSugar: SyntacticSugar?
    
    /// A value that represents the scope of the signature
    /// The larger the scope, the more universally applicable the function.
    var scope: Int {
        return signature.reduce(0) {$0 + $1.rawValue}
    }
    
    init(_ name: String, _ signature: [ArgumentType], syntacticSugar: SyntacticSugar? = nil, definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.signature = signature
        self.syntacticSugar = syntacticSugar
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
            // Operations with the smaller scope should be prioritized.
            .sorted{$0.scope < $1.scope}
        candLoop: for cand in candidates {
            if cand.signature.first == .universal {
                return cand
            } else if cand.signature.count != args.count {
                continue
            }
            for i in 0..<cand.signature.count {
                let argType = cand.signature[i]
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
     Two parametric operations are equal to each other if they have the same name
     and the same signature
     */
    static func == (lhs: ParametricOperation, rhs: ParametricOperation) -> Bool {
        return lhs.name == rhs.name && lhs.signature == rhs.signature
    }
}
