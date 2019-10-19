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
        Exports.core,
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
    public let scope: Int
    
    /// Definition of the operation that transforms arguments, aka. `[Node]` into a result `Node?`.
    public let def: Definition
    
    /// Name of the operation. A String.
    public let name: OperationName
    
    /// Number of parameters to take in, since some operations have variatic parameters, this value is optional.
    public private(set) var numArgs: Int?
    
    /// Parameter requirements of the operation. The name and parameters of the operation consists the signature.
    public let parameters: [Parameter]

    /// Creates a new operation from `name`, `parameters`, and `definition`.
    /// Note that it is not automatically registered.
    init(_ name: OperationName, _ parameters: [Parameter], definition: @escaping Definition) {
        self.name = name
        self.def = definition
        self.parameters = parameters
        // Scope is calculated by summing up the specificity of argument requirements.
        self.scope = parameters.reduce(0) { $0 + $1.scope }
        self.countArgs()
    }
    
    /// Counts the number of arguments.
    private func countArgs() {
        var c = 0
        for par in parameters {
            switch par.multiplicity {
            case .unary:
                c += 1
            case .count(let n):
                c += n
            case .any:
                return
            }
        }
        self.numArgs = c
    }
    
    /// Generates a hash from description, since each unique operation has a unique description.
    public func hash(into hasher: inout Hasher) {
        description.hash(into: &hasher)
    }
    
    /// Generate the conjugate definition for the given operation.
    /// e.g. The parameters type `[.node, .function]` becomes `[.function, .node]`.
    /// The premise is that the given operation is commutative, otherwise nil is returned.
    ///
    /// - Parameter operation: A commutative operation.
    /// - Returns: The conjugate definition for the operation, that is, if it exists at all.
    private static func conjugate(for operation: Operation) -> Operation? {
        if operation.parameters.count == 2 && operation.name[.commutative] {
            // The original com. op. w/ parameters and def. reversed.
            let op = Operation(operation.name, operation.parameters.reversed()) {
                return try operation.def($0.reversed())
            }
            return op
        }
        return nil
    }

    /// Registers the operation s.t. it is visible within Kelvin.
    public static func register(_ operation: Operation, isUserDefined: Bool = true) {
        if isUserDefined {
            userDefined.insert(operation)
        }
        let name = operation.name
        var arr = registered[name] ?? [Operation]()
        arr.append(operation)
        if let conjugate = Operation.conjugate(for: operation) {
            // Register the conjugate as well, if it exists.
            arr.append(conjugate)
        }
        arr.sort {$0.scope < $1.scope}
        registered.updateValue(arr, forKey: name)
    }

    /// Finds the conjugates of commutative operations, then assort all operations by
    /// their names into a dictionary. This results in a 75% performance boost!
    private static func process(_ operations: [Operation]) -> [OperationName: [Operation]] {
        var operations = operations
        let conjugates = operations.map { conjugate(for: $0) }.compactMap { $0 }
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
    ///    - parameters: The parameters of the operation to be removed.
    public static func remove(_ name: OperationName, _ parameters: [Parameter]) {
        let parOp = Operation(name, parameters) { _ in
            nil
        }
        registered[name]?.removeAll { $0 == parOp }
    }

    /// Remove the parametric operations with the given name.
    /// - Parameter name: The name of the operations to be removed.
    public static func remove(_ name: OperationName) {
        registered[name] = nil
    }
    
    /// - Parameter fun: The function that supplies the arguments to the operation.
    /// - Returns: True if the operation can be applied on the function. That is, the arguments of the function
    ///            matches the requirements of the operation specified by its parameters.
    private func canApply(to fun: Function) -> Bool {
        var args = fun.elements
        
        /// Checks if the first argument in `args` matches the parameter.
        /// If so, it is removed and `true` is returned; otherwise returns `false`.
        func matches(_ par: Parameter) -> Bool {
            if let arg = args.first, KType.resolve(arg).is(par.kType) {
                args.removeFirst()
                return true
            }
            return false
        }
        
        /// Ensure that requirements specified by the parameter is satisfied by the arguments of the function.
        for par in parameters {
            switch par.multiplicity {
            case .unary:
                // Requires a single parameter
                guard matches(par) else { return false }
            case .count(let c):
                // Requires a specific number of the same parameter
                var i = 0
                while i < c {
                    guard matches(par) else {
                        return false
                    }
                    i += 1
                }
            case .any:
                // Requires any number of the specified paramter.
                while matches(par) {}
            }
        }
        
        return args.count == 0
    }

    /// Resolves the appropriate operation based on the name and provided arguments.
    ///
    /// - Parameter fun: The function that requires an operation as its definition.
    /// - Parameter args: The arguments supplied to the operation
    /// - Returns: A list of operations with matching parameters, sorted in order of increasing scope.
    public static func resolve(for fun: Function) -> [Operation] {
        // First find all operations w/ the given name.
        // If there are none, return an empty array.
        guard let cands = registered[fun.name] else { return [] }
        // Candidates are already sorted in ascending order by scope.
        return cands.filter { $0.canApply(to: fun)}
    }

    /// Two parametric operations are equal to each other if they have the same name and the same parameters
    public static func ==(lhs: Operation, rhs: Operation) -> Bool {
        return lhs.name == rhs.name && lhs.parameters == rhs.parameters
    }
}

extension Operation: CustomStringConvertible {
    public var description: String {
        let parameterTypes = parameters.reduce(nil) {
            $0 == nil ? $1.description : "\($0!),\($1.description)"
        } ?? ""
        return "\(name)(\(parameterTypes))"
    }
}
