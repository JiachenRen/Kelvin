//
//  Operator.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/9/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public class Operation: Equatable, Hashable {
    /// Operations that are resolved dynamically and bound to functions with matching signature.
    public static var registered: [OperationName: [Operation]] = {
        return process(defaults)
    }()
    
    /// Built in operations
    public static let defaults: [Operation] = [
        Exports.algebra,
        Exports.list,
        Exports.matrix,
        Exports.pair,
        Exports.probability,
        Exports.rules,
        Exports.stats,
        Exports.vector,
        Exports.strings,
        Exports.calculus,
        Exports.core,
        Exports.iterable,
        Exports.fileSystem,
        Exports.flowControl,
        Exports.stackTrace
    ].flatMap {
        $0
    }
    
    /// User defined functions
    private(set) static var userDefined = Set<Operation>()

    /// A value that represents the scope of the signature
    /// The larger the scope, the more universally applicable the function.
    let scope: Int

    public let def: Definition
    public let name: OperationName
    public let signature: [ParameterType]

    init(_ name: OperationName, _ signature: [ParameterType], definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.signature = signature
        
        // Scope is calculated by summing up the specificity of argument requirements.
        self.scope = signature.reduce(0) {
            $0 + $1.rawValue
        }
    }
    
    /// Generates a hash from description, since each unique operation has a unique description.
    public func hash(into hasher: inout Hasher) {
        description.hash(into: &hasher)
    }
    
    /// Generate the conjugate definition for the given operation.
    /// e.g. The signature type `[.any, .func]` becomes `[.func, .any]`.
    /// The premise is that the given operation is commutative, otherwise nil is returned.
    ///
    /// - Parameter operation: A commutative operation.
    /// - Returns: The conjugate definition for the operation, that is, if it exists at all.
    private static func conjugate(for operation: Operation) -> Operation? {
        if operation.signature.count == 2 && operation.name[.commutative] {

            // The original com. op. w/ signature and def. reversed.
            let op = Operation(operation.name, operation.signature.reversed()) {
                return try operation.def($0.reversed())
            }
            return op
        }
        return nil
    }

    /// Register the operation.
    public static func register(_ operation: Operation, isUserDefined: Bool = true) {
        if isUserDefined {
            userDefined.insert(operation)
        }
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
    private static func process(_ operations: [Operation]) -> [OperationName: [Operation]] {
        var operations = operations

        let conjugates = operations
            .map {conjugate(for: $0)}
            .compactMap {$0}

        operations.append(contentsOf: conjugates)
        var dict = [OperationName: [Operation]]()
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

    /// Clear existing registered operations, user defined operations, then register default operations.
    public static func restoreDefault() {
        userDefined = []
        registered = process(defaults)
    }

    /// Remove a parametric operation from registration.
    ///
    /// - Parameters:
    ///    - name: The name of the operation to be removed.
    ///    - signature: The signature of the operation to be removed.
    static func remove(_ name: OperationName, _ signature: [ParameterType]) {
        let parOp = Operation(name, signature) { _ in
            nil
        }
        registered[name]?.removeAll {
            $0 == parOp
        }
    }

    /// Remove the parametric operations with the given name.
    /// - Parameter name: The name of the operations to be removed.
    static func remove(_ name: OperationName) {
        registered[name] = nil
    }

    /// Resolves the appropriate operation based on the name and provided arguments.
    ///
    /// - Parameter fun: The function that requires an operation as its definition.
    /// - Parameter args: The arguments supplied to the operation
    /// - Returns: A list of operations with matching signature, sorted in order of increasing scope.
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
                    signature = [ParameterType](repeating: .any, count: fun.count)
                case .numbers:
                    signature = [ParameterType](repeating: .number, count: fun.count)
                case .booleans:
                    signature = [ParameterType](repeating: .bool, count: fun.count)
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
                case .pair where !(arg is Pair):
                    fallthrough
                case .var where !(arg is Variable):
                    fallthrough
                case .type where !(arg is KType):
                    fallthrough
                case .bool where !(arg is Bool):
                    fallthrough
                case .vec where !(arg is Vector):
                    fallthrough
                case .matrix where !(arg is Matrix):
                    fallthrough
                case .list where !(arg is List):
                    fallthrough
                case .iterable where !(arg is Iterable):
                    fallthrough
                case .number where !(arg is Value):
                    fallthrough
                case .nan where arg is Value:
                    fallthrough
                case .equation where !(arg is Equation):
                    fallthrough
                case .string where !(arg is KString):
                    fallthrough
                case .int where !(arg is Int):
                    fallthrough
                case .closure where !(arg is Closure):
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

    /// Commutatively simplify a list of arguments. Suppose we have an expression,
    /// `1 + a + negate(1) + negate(a)`.
    /// First, we check if `1 + a` is simplifiable, in this case no.
    /// Then, we check if `1 + negate(1)` is simplifiable, if so, simplify and put them back into the pool.
    /// At this point, we have `a + negate(a) + 0`, which then easily simplifies to 0.
    ///
    /// - Parameter nodes: The list of nodes to be commutatively simplified.
    /// - Parameter fun: A function that performs binary simplification.
    /// - Returns: A node resulting from the simplification.
    public static func simplifyCommutatively(_ nodes: [Node], by fun: OperationName) throws -> Node {
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

    /// Two parametric operations are equal to each other if they have the same name and the same signature
    public static func ==(lhs: Operation, rhs: Operation) -> Bool {
        return lhs.name == rhs.name && lhs.signature == rhs.signature
    }
}

extension Operation: CustomStringConvertible {
    public var description: String {
        let parameterTypes = signature.reduce(nil) {
            $0 == nil ? $1.name : "\($0!),\($1.name)"
        } ?? ""
        return "\(name)(\(parameterTypes))"
    }
}
