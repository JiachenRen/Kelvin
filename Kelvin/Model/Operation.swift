//
//  Operator.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/9/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

typealias Definition = ([Node]) throws -> Node?

/// Numerical unary operation
typealias NUnary = (Double) -> Double

/// Numerical binary operation
typealias NBinary = (Double, Double) -> Double

public class Operation: Equatable {

    /// Registered operations are resolved dynamically during runtime
    /// and assigned to functions with matching signature as definitions.
    public static var registered: [String: [Operation]] = {
        return process(defaults)
    }()
    
    /// Collect all built-in operations and combine them into a single
    /// operations array.
    public static let defaults: [Operation] = [
        binaryOperations,
        unaryOperations,
        statOperations,
        probabilityOperations,
        algebraicOperations,
        developerOperations,
        listAndTupleOperations,
        equalityOperations,
        conversionOperations,
        calculusOperations,
        vectorOperations
    ].flatMap {
        $0
    }

    /// Use this dictionary to assign special attributes to operations.
    /// e.g. since + and * are commutative, the "commutative" flag should be assigned to them.
    public static var configuration: [Attribute: [String]] = {
        defaultConfiguration
    }()

    /// A value that represents the scope of the signature
    /// The larger the scope, the more universally applicable the function.
    let scope: Int

    let def: Definition
    let name: String
    let signature: [ArgumentType]

    init(_ name: String, _ signature: [ArgumentType], definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.signature = signature
        
        // Scope is calculated by summing up the specificity of argument requirements.
        self.scope = signature.reduce(0) {
            $0 + $1.rawValue
        }
    }

    /**
     Generate the conjugate definition for the given operation.
     e.g. The signature type [.any, .func] becomes [.func, .any].
     The premise is that the given operation is commutative, otherwise nil is returned.
     
     - Parameter operation: A commutative operation.
     - Returns: The conjugate definition for the operation, that is, if it exists at all.
     */
    private static func conjugate(for operation: Operation) -> Operation? {
        if operation.signature.count == 2 && has(attr: .commutative, operation.name) {

            // The original com. op. w/ signature and def. reversed.
            let op = Operation(operation.name, operation.signature.reversed()) {
                return try operation.def($0.reversed())
            }
            return op
        }
        return nil
    }

    /// Register the operation.
    public static func register(_ operation: Operation) {
        var arr = registered[operation.name] ?? [Operation]()
        arr.append(operation)
        

        if let conjugate = Operation.conjugate(for: operation) {

            // Register the conjugate as well, if it exists.
            arr.append(conjugate)
        }
        
        arr.sort {$0.scope < $1.scope}
        registered.updateValue(arr, forKey: operation.name)
    }

    /// Find the conjugates of commutative operations, then assort all operations by
    /// their names into a dictionary. This results in a 75% performance boost!
    private static func process(_ operations: [Operation]) -> [String: [Operation]] {
        var operations = operations

        let conjugates = operations.map {
                    conjugate(for: $0)
                }
                .filter {
                    $0 != nil
                }
                .map {
                    $0!
                }

        operations.append(contentsOf: conjugates)
        var dict = [String: [Operation]]()
        for operation in operations {
            let name = operation.name
            if var arr = dict[name] {
                arr.append(operation)
                dict.updateValue(arr, forKey: name)
            } else {
                dict[name] = [operation]
            }
        }
        
        dict.forEach {(key, value) in
            let sorted = dict[key]!.sorted {
                $0.scope < $1.scope
            }
            dict.updateValue(sorted, forKey: key)
        }
        
        return dict
    }

    /// Clear the existing registered operations, then
    /// load the default definitions and configurations from Definitions.swift
    public static func restoreDefault() {

        // Restore to default configuration
        self.configuration = defaultConfiguration

        // Process and register default operations.
        registered = process(defaults)
    }

    /**
     Remove a parametric operation from registration.
     
     - Parameters:
     - name: The name of the operation to be removed.
     - signature: The signature of the operation to be removed.
     */
    static func remove(_ name: String, _ signature: [ArgumentType]) {
        let parOp = Operation(name, signature) { _ in
            nil
        }
        registered[name]?.removeAll {
            $0 == parOp
        }
    }

    /// Remove the parametric operations with the given name.
    /// - Parameter name: The name of the operations to be removed.
    static func remove(_ name: String) {
        registered[name] = nil
    }

    /**
     Resolves the corresponding parametric operation based on the name and provided arguments.
     
     - Parameter fun: The function that requires an operation as its definition.
     - Parameter args: The arguments supplied to the operation
     - Returns: A list of operations with matching signature, sorted in order of increasing scope.
     */
    public static func resolve(for fun: Function) -> [Operation] {
        
        // First find all operations w/ the given name.
        // If there are none, return an empty array.
        guard let candidates = registered[fun.name] else {
            return []
        }
        
        var matching = [Operation]()

        candLoop: for cand in candidates {
            var signature = cand.signature

            // Deal w/ function signature types that allow any # of args.
            if let first = signature.first {
                switch first {
                case .multivariate where fun.count <= 1:
                    break candLoop
                case .multivariate:
                    fallthrough
                case .universal:
                    signature = [ArgumentType](repeating: .any, count: fun.count)
                case .numbers:
                    signature = [ArgumentType](repeating: .number, count: fun.count)
                case .booleans:
                    signature = [ArgumentType](repeating: .bool, count: fun.count)
                default: break
                }
            }

            // Bail out if # of parameters does not match # of args.
            if signature.count != fun.count {
                continue
            }

            // Make sure that each parameter is the required type
            for i in 0..<signature.count {
                let argType = signature[i]
                let arg = fun[i]
                switch argType {
                case .any:
                    continue
                case .leaf where !(arg is LeafNode):
                    fallthrough
                case .tuple where !(arg is Tuple):
                    fallthrough
                case .var where !(arg is Variable):
                    fallthrough
                case .bool where !(arg is Bool):
                    fallthrough
                case .vec where !(arg is Vector):
                    fallthrough
                case .list where !(arg is List):
                    fallthrough
                case .iterable where !(arg is MutableListProtocol):
                    fallthrough
                case .number where !(arg is NSNumber):
                    fallthrough
                case .nan where arg is NSNumber:
                    fallthrough
                case .equation where !(arg is Equation):
                    fallthrough
                case .string where !(arg is String):
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
    public static func simplifyCommutatively(_ nodes: [Node], by fun: String) throws -> Node {
        var nodes = nodes

        if nodes.count == 2 {

            // Base case.
            return try Function(fun, nodes).simplify()
        }

        for i in 0..<nodes.count - 1 {
            let n = nodes.remove(at: i)
            for j in i..<nodes.count {

                let bin = Function(fun, [nodes[j], n])
                let simplified = try bin.simplify()

                // If the junction of n and j can be simplified...
                if simplified.complexity < bin.complexity {
                    nodes.remove(at: j)
                    nodes.append(simplified)

                    // Commutatively simplify the updated list of nodes
                    return try simplifyCommutatively(nodes, by: fun)
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
     - Parameters:
     - name: The name of the function
     - attr: The attribute in question such as .commutative
     - Returns: Whether the function w/ the given name has the designated attribute
     */
    public static func has(attr: Attribute, _ name: String) -> Bool {
        return configuration[attr]!.contains(name)
    }

    /**
     Two parametric operations are equal to each other if they have the same name
     and the same signature
     */
    public static func ==(lhs: Operation, rhs: Operation) -> Bool {
        return lhs.name == rhs.name && lhs.signature == rhs.signature
    }

    /**
     This enum is used to represent the type of the arguments.
     By giving a function a name, the number of arguments,
     and the types of arguments, we can generate a unique signature
     that is used later to find definitions.
     */
    enum ArgumentType: Int, Equatable {
        case int = 1
        case double
        case number
        case nan
        case `var`
        case `func`
        case bool
        case equation
        case string
        case vec
        case list
        case tuple
        case iterable
        case leaf
        case any = 100
        case numbers = 1000
        case booleans = 1001
        case multivariate = 4000 // Takes in more than 1 argument
        case universal = 10000 // Takes in any # of args.
    }

    /// Flags that denote special attributes for certain operations.
    public enum Attribute: Hashable {

        /// Debugging and flow control functions like "complexity" and "repeat"
        /// should not simplify args before their execution.
        case preservesArguments

        /// Addition, multiplication, and boolean logic are all commutative
        /// Commutative functions with the same name should only be marked once.
        case commutative

        /// Operations with this flag are only commutative in the forward direction.
        /// e.g. division and subtraction.
        case forwardCommutative
    }
}
