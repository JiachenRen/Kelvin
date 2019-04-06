//
//  Function.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Function: MutableListProtocol {
    
    public var evaluated: Value? {
        return (((try? invoke()) as Node??))??.evaluated
    }

    /// Complexity of the function is the complexity of the List of args + 1.
    public var complexity: Int {
        return args.complexity
    }

    /// The name of the function
    public let name: String

    /// List of arguments that the function takes in.
    public let args: List
    
    /// Conform to MutableListProtocol by returning the list of arguments
    /// as elements; since the function itself is immutable, a new function
    /// is created every time the elements are changed.
    public var elements: [Node] {
        get {
            return args.elements
        }
        set {
            self = Function(name, List(newValue))
        }
    }

    /// The syntactic rules of the function (looked up by the name)
    var keyword: Keyword? {
        return Keyword.glossary[name]
    }
    
    public var precedence: Keyword.Precedence {
        return keyword?.precedence ?? .node
    }
    
    /// Whether the function is commutative.
    public let isCommutative: Bool

    public init(_ name: String, _ args: List) {
        self.name = name
        self.isCommutative = name[.commutative]
        
        // If the function is commutative, order its arguments.
        self.args = isCommutative ? args.ordered() : args
        flatten()
    }

    public init(_ name: String, _ args: [Node]) {
        self.init(name, List(args))
    }

    public var stringified: String {
        return toString()
    }
    
    public var ansiColored: String {
        return toString(colored: true)
    }
    
    private var ansiFormattedName: String {
        return Operation.registered[name] == nil ? name : name.bold.italic
    }

    private func parenthesize(_ s: String, _ colored: Bool) -> String {
        return colored ? "(".bold + s + ")".bold : "(\(s))"
    }
    
    private func toString(colored: Bool = false) -> String {
        let r = elements.map {
            colored ? $0.ansiColored : $0.stringified
        }
        var n = " \(colored ? ansiFormattedName : name) "
        
        func formatted() -> String {
            let l = r.reduce(nil) {
                $0 == nil ? "\($1)" : "\($0!), \($1)"
            }
            return "\(colored ? ansiFormattedName : name)\(parenthesize(l ?? "", colored))"
        }
        
        if let keyword = self.keyword {
            
            // Determine which form of the function to use;
            // there are three options: shorthand, operator, or default.
            let k = keyword.formatted
            let n = colored ? (k.replacingOccurrences(of: " ", with: "").isAlphanumeric ? k.bold : k) : k
            
            switch keyword.associativity {
            case .infix where count == 1:
                
                // Handle special case of -x.
                let c = keyword.operator?.name ?? (colored ? ansiFormattedName : name)
                return "\(c)\(r[0])"
            case .infix where args.count == 2 || isCommutative:
                if let s = r.enumerated().reduce(nil, { (a, c) -> String in
                    let (i, b) = c
                    let p = usesParenthesis(forNodeAtIndex: i)
                    let b1 = p ? parenthesize(b, colored) : "\(b)"
                    return a == nil ? "\(b1)" : "\(a!)\(n)\(b1)"
                }) {
                    return "\(s)"
                } else {
                    return ""
                }
            case .prefix where r.count == 1:
                let p = usesParenthesis(forNodeAtIndex: 0)
                return p ? "\(n)\(parenthesize(r[0], colored))" : "\(n)\(r[0])"
            case .postfix where r.count == 1:
                let p = usesParenthesis(forNodeAtIndex: 0)
                return p ? "\(parenthesize(r[0], colored))\(n)" : "\(r[0])\(n)"
            default:
                break
            }
        }
        
        return formatted()
    }

    /**
     Whether the child node should be enveloped in parenthesis when printing.
     If the parent and the child are both commutative and have the same name,
     then the parenthesis for the child is omitted; otherwise if the child's
     precedence is larger than that of the parent, the parenthesis is also omitted.
     
     - Note: Parentheses only apply to infix operations.
     - Parameter idx: The index of the child.
     - Returns: Whether a parenthesis should be used for the child when printing.
     */
    private func usesParenthesis(forNodeAtIndex idx: Int) -> Bool {
        let child = args[idx]
        if child.precedence < precedence {

            // e.g. (a + b) * c
            // If the child's precedence is lower, a parenthesis is always needed.
            return true
        } else if child.precedence == precedence {
            if idx != 0 && name[.forwardCommutative] {
                return true
            }
        }
        return false
    }

    /**
     Resolve the operations associated w/ the function and then perform
     perform them on the arguements.
     
     - Returns: The first successful result acquired by performing the
                operations on the arguments.
     */
    public func invoke() throws -> Node? {
        for operation in Operation.resolve(for: self) {
            if let result = try operation.def(elements) {
                return result
            }
        }
        return nil
    }

    /**
     Simplify each argument, if possible, then perform the operation defined by this
     function on the arguments, if possible. Otherwise, a copy of the original function
     is returned, with each argument simplified.
     
     - Returns: a node representing the simplified(computed) value of the function.
     */
    public func simplify() throws -> Node {

        // Make a copy of self.
        var copy = self
        
        do {
            // Simplify each argument, if requested.
            if !name[.preservesArguments] {
                let preservesFirst = name[.preservesFirstArgument]
                let args = try copy.elements.enumerated().map {(arg) -> Node in
                    let (i, e) = arg
                    if preservesFirst && i == 0 {
                        return e
                    }
                    return try e.simplify()
                }
                copy = Function(name, args)
            }

            // If the operation can be performed on the given arguments, perform the operation.
            // Then, the result of the operation is simplified;
            // otherwise returns a copy of the original function with each argument simplified.
            if let s = try copy.invoke()?.simplify() {
                return s
            } else if name[.commutative] {
                // Try simplifying in the reserve order if the function is commutative
                if copy.count > 2 {
                    let after = try Operation.simplifyCommutatively(copy.elements, by: name)
                    return after.complexity < copy.complexity ? after : copy
                }
            }

            // Cannot be further simplified
            return copy
        } catch let e as KelvinError {
            throw ExecutionError.onNode(self, err: e)
        }
    }
    
    public func implement(using template: Node) throws {
        // Create function signature
        let signature = [ParameterType](repeating: .any, count: args.count)
        
        // Make sure the old definition is removed from registry
        Operation.remove(name, signature)
        
        // Check to make sure that every argument is a variable
        for arg in args.elements {
            if !(arg is Variable) {
                let msg = "expecting parameter name, instead found \(arg.stringified)"
                throw ExecutionError.general(errMsg: msg)
            }
        }
        
        // Cast the arguments to variables
        let parameters = args.map {
            $0 as! Variable
        }
        
        // Create and register function denition as an operation
        let def = try Function.createDefinition(from: template, using: parameters)
        let op = Operation(name, signature, definition: def)
        Operation.register(op)
    }
    
    /// Creates a definition from the template, by replacing
    /// the variables in template with arguments
    public static func createDefinition(from template: Node, using parameters: [Variable]) throws -> Definition {
        
        // Generate a unique tag
        let tag = Keyword.Encoder.next()
        
        var dict = parameters.reduce(into: [:]) {
            $0[$1.name] = "\(tag)\($1.name)"
        }
        
        let template = template.replacing(by: {
            var rpl = $0 as! Variable
            
            // This is for dealing with the following senario:
            // Suppose we have f(x) = x^2, then call to f({x})
            // will cause infinite recursion. This prevents it by
            // tagging the function variables.
            rpl.name = dict[rpl.name]!
            return rpl
        }, where: {n in
            if let v = n as? Variable {
                return parameters.contains {v === $0}
            }
            return false
        })
        
        return { args in
            Scope.save()
            
            var inoutArgs = [String: Variable]()
            try zip(parameters, args).forEach {(par, arg) in
                var arg = arg
                
                // Find all inout variables, extract their definitions
                if let fun = arg as? Function, fun.name == .inout {
                    guard fun.count == 1, let inoutArg = fun[0] as? Variable else {
                        let msg = "expecting variable name after inout modifier, instead found \(fun[0].stringified)"
                        throw ExecutionError.general(errMsg: msg)
                    }
                    inoutArgs[inoutArg.name] = par
                    if Variable.definitions[inoutArg.name] == nil {
                        let msg = "variable \(inoutArg.stringified) is undefined; inout modifier can only be used on variables with definitions"
                        throw ExecutionError.general(errMsg: msg)
                    }
                    arg = try inoutArg.simplify()
                }
                Variable.define(dict[par.name]!, arg)
            }
            
            let result = try template.simplify()
                .replacing(by: { (n) -> Node in
                    let v = n as! Variable
                    return Variable.definitions[v.name]!
                }, where: {
                    ($0 as? Variable)?.name.first == tag
                })
            
            // Escaping definitions for inout variables
            let escaping = inoutArgs.reduce(into: [:]) {
                $0[$1.key] = Variable.definitions[dict[$1.value.name]!]
            }
            
            Scope.restore()
            
            // Escape inout variable definitions
            for (v, def) in escaping {
                Variable.definitions[v] = def
            }
            
            return result
        }
    }

    /**
     Unravel the binary operation tree.
     e.g. +(d,+(+(a,b),c)) becomes +(a,b,c,d)
     
     - Warning: Before invoking this function, the expression should be in addtion only form.
     Under normal circumstances, don't use this function.
     */
    private mutating func flatten() {
        let elements = self.elements
        
        // Flatten commutative operations
        if isCommutative {
            var newArgs = [Node]()
            var changed = false
            elements.forEach { arg in
                if let fun = arg as? Function, fun.name == name {
                    changed = true
                    newArgs.append(contentsOf: fun.elements)
                } else {
                    newArgs.append(arg)
                }
            }

            // Prevent stackoverflow due to recursive calling to args' setter
            if changed {
                self = Function(name, List(newArgs))
            }
        }
    }

    /// Functions are equal to each other if their names and arguments are the same
    public func equals(_ node: Node) -> Bool {
        if let fun = node as? Function {
            if fun.name == name {
                if equals(list: fun as ListProtocol) {
                    return true
                }
            }
        }
        return false
    }
}
