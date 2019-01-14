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
        case nan = 1
        case `var` = 2
        case `func` = 3
        case bool = 4
        case list = 5
        case equation = 6
        case any = 100
        case numbers = 1000
        case booleans = 1001
        case universal = 10000 // Takes in any # of args.
    }
    
    /// Flags that denote special attributes for certain operations.
    public enum Flag {
        
        /// Debugging and flow control functions like "complexity" and "repeat"
        /// should not simplify args before their execution.
        case preservesArguments
        
        /// Addition, multiplication, and boolean logic are all commutative
        /// Commutative functions with the same name should only be marked once.
        case isCommutative
    }
    
    /// Registered operations are resolved dynamically during runtime
    /// and assigned to functions with matching signature as definitions.
    static var registered = [Operation]()
    
    /// Use this dictionary to assign special attributes to operations.
    /// e.g. since + and * are commutaive, the "commutative" flag should be assigned to them.
    static var configuration = [Flag: [String]]()
    
    /// A value that represents the scope of the signature
    /// The larger the scope, the more universally applicable the function.
    var scope: Int {
        return signature.reduce(0) {$0 + $1.rawValue}
    }
    
    let def: Definition
    let name: String
    let signature: [ArgumentType]
    let syntax: Syntax?
    
    init(_ name: String, _ signature: [ArgumentType], syntax: Syntax? = nil, definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.signature = signature
        self.syntax = syntax
    }
    
    /// Register the parametric operation.
    public static func register(_ operation: Operation) {
        registered.append(operation)
    }
    
    /// Clear the existing registered operations, then
    /// load the default definitions and configurations from Definitions.swift
    public static func reloadDefinitions() {
        
        // Restore to default configuration
        self.configuration = defaultConfig
        
        // Clear existing registrations
        registered = []
        
        // Register default definitions
        definitions.forEach{Operation.register($0)}
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
     - Returns: A list of operations with matching signature, sorted in order of increasing scope.
     */
    public static func resolve(_ name: String, args: [Node]) -> [Operation] {
        let candidates = registered.filter{$0.name == name}
            // Operations with the smaller scope should be prioritized.
            .sorted{$0.scope < $1.scope}
        
        var matching = [Operation]()
        
        candLoop: for cand in candidates {
            var signature = cand.signature
            
            // Deal w/ function signature types that allow any # of args.
            if let first = signature.first {
                switch first {
                case .universal:
                    signature = [ArgumentType](repeating: .any, count: args.count)
                case .numbers:
                    signature = [ArgumentType](repeating: .number, count: args.count)
                case .booleans:
                    signature = [ArgumentType](repeating: .bool, count: args.count)
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
                case .number where !(arg is NSNumber):
                    fallthrough
                case .nan where arg is NSNumber:
                    fallthrough
                case .equation where !(arg is Equation):
                    fallthrough
                case .func where !(arg is Function):
                    continue candLoop
                default: continue
                }
            }
            
            matching.append(cand)
        }
        
        return matching
    }
    
    /**
     Commutatively simplify a list of arguments.
     Suppose we have an expression, 1 + a + negate(1) + negate(a);
     First, we check if 1 + a is simplifiable, in this case no.
     Then, we check if 1 + negate(1) is simplifiable, if so,
     simplify and put them back into the pool. At this point,
     we have "a + negate(a) + 0", which then easily simplifies to 0.
     
     - Parameter nodes: The list of nodes to be commutatively simplified.
     - Parameter fun: A function that performs binary simplification.
     - Returns: A node resulting from the simplification.
     */
    public static func simplifyCommutatively(_ nodes: [Node], by fun: String) -> Node {
        var nodes = nodes
        
        func simplifyBidirectionally(_ nodes: [Node]) -> Node? {
            // Make sure we are only taking in 2 arguments
            assert(nodes.count == 2)
            let forward = Function(fun, [nodes[0], nodes[1]])
            let backward = Function(fun, [nodes[1], nodes[0]])
            
            let originals = [forward, backward]
            
            // Simplification could be forward or backward; in that case,
            // perform simplification for both ways and compare them.
            for bin in originals {
                let simplified = bin.simplify()
                
                // If the junction of i and j can be simplified...
                if simplified.complexity < bin.complexity {
                    return simplified
                }
            }
            
            return nil
        }
        
        if nodes.count == 2 {
            
            // Reverse the order of arguments and simplify again!
            return Function(fun, nodes.reversed()).simplify()
        }
        
        for i in 0..<nodes.count - 1 {
            let n = nodes.remove(at: i)
            for j in i..<nodes.count {
                if let simplified = simplifyBidirectionally([nodes[j], n]) {
                    nodes.remove(at: j)
                    nodes.append(simplified)
                    
                    // Commutatively simplify the updated list of nodes
                    return simplifyCommutatively(nodes, by: fun)
                }
            }
            
            // Can't perform simplification w/ current node.
            // Insert it back in and move on to the next.
            nodes.insert(n, at: i)
        }
        
        // Fully simplified. Reconstruct commutative operation and return.
        return Function(fun, nodes)
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
     - Parameters:
        - name: The name of the function
        - flag: The flag in question such as .isCommutaive
     - Returns: Whether the function w/ the given name has the designated flag
     */
    public static func hasFlag(_ name: String, _ flag: Flag) -> Bool {
        return configuration[flag]!.contains(name)
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
