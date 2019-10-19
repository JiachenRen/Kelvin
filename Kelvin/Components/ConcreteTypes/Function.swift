//
//  Function.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public class Function: ListProtocol, NaN {
    public var evaluated: Number? { try? invoke()?.evaluated }
    public var elements: [Node]
    public let name: OperationName
    public let isCommutative: Bool
    var keyword: Keyword? { Syntax.glossary[name] }

    public required init(_ name: String, _ args: [Node]) {
        self.name = name
        self.isCommutative = name[.commutative]
        self.elements = args
        if isCommutative {
            order()
        }
        flatten()
    }

    /// Resolve the operations associated w/ the function and then perform them on the arguements.
    /// - Returns: The first successful result acquired by performing the operations on the arguments.
    public func invoke() throws -> Node? {
        for operation in Operation.resolve(for: self) {
            if let result = try operation.def(elements) {
                return result
            }
        }
        return nil
    }
    
    public func implement(using template: Node) throws {
        // Create function parameters
        let parameters = [Parameter](repeating: .node, count: count)
        // Make sure the old definition is removed from registry
        Operation.remove(name, parameters)
        
        // Check to make sure that every argument is a variable
        for arg in elements {
            if !(arg is Variable) {
                let msg = "expecting parameter name, instead found \(arg.stringified)"
                throw ExecutionError.general(errMsg: msg)
            }
        }
        
        // Cast the arguments to variables
        let variables = elements.map {
            $0 as! Variable
        }
        
        // Create and register function denition as an operation
        let def = try Function.createDefinition(from: template, using: variables)
        let op = Operation(name, parameters, definition: def)
        Operation.register(op)
    }
    
    /// Creates a definition from the template, by replacing the variables in template with arguments
    public static func createDefinition(from template: Node, using parameters: [Variable]) throws -> Definition {
        
        // Generate a unique tag
        let tag = Tokenizer.next()
        
        let dict = parameters.reduce(into: [:]) {
            $0[$1.name] = "\(tag)\($1.name)"
        }
        
        let template = template.replacing(by: {
            let rpl = $0 as! Variable
            
            // This is for dealing with the following senario:
            // Suppose we have f(x) = x^2, then call to f({x})
            // will cause infinite recursion. This prevents it by
            // tagging the function variables.
            rpl.name = dict[rpl.name]!
            return rpl
        }, where: {n in
            if let v = n as? Variable {
                return dict[v.name] != nil
            }
            return false
        })
        
        return { args in
            // Push variable scope
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
            
            // Inject higher order functions into definition
            var injected: Node = template
            for (i, arg) in args.enumerated() where arg is Function {
                let fun = arg as! Function
                if fun.name != .functionRef {
                    continue
                }
                injected = try injected.replacing(by: {
                    let org = $0 as! Function
                    guard let new = fun.elements.first as? Variable else {
                        let msg = "'\(fun.stringified)' is not a valid function reference"
                        throw ExecutionError.general(errMsg: msg)
                    }
                    return Function(new.name, org.copy().elements)
                }) {
                    ($0 as? Function)?.name == parameters[i].name
                }
            }
            
            // Link arguments and parameters
            let result = try injected.simplify()
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
            
            // Pop variable scope
            Scope.restore()
            
            // Escape inout variable definitions
            Variable.definitions.merge(escaping) {
                (org, esc) in esc
            }
            
            return result
        }
    }

    /// Flattens functions marked as commutative.
    /// e.g. `(d+((a+b)+c))` becomes `(a+b+c+d)`
    ///
    /// - Warning: Before invoking this function, the expression should be in addtion only form.
    /// Under normal circumstances, don't use this function.
    private func flatten() {
        guard isCommutative else { return }
        var newArgs = [Node]()
        for arg in elements {
            if let fun = arg as? Function, fun.name == name {
                newArgs.append(contentsOf: fun.elements)
            } else {
                newArgs.append(arg)
            }
        }
        elements = newArgs
    }
    
    // MARK: - Node
    
    /// Simplify each argument, if possible, then perform the operation defined by this
    /// function on the arguments, if possible. Otherwise, a copy of the original function
    /// is returned, with each argument simplified.
    ///
    /// - Returns: a node representing the simplified(computed) value of the function.
    public func simplify() throws -> Node {
        // Push current function invocation onto the stack
        StackTrace.shared.add(.push, self, name)
        // Prevent against stack overflow
        Program.shared.curStackSize += 1
        try Program.shared.checkStackLimit()
        // Make a copy of self.
        var copy = self
        // Manual deferral of stack operations.
        let finalize: (Node) -> Node = { [unowned self] node in
            Program.shared.curStackSize -= 1
            StackTrace.shared.add(.pop, node, self.name)
            return node
        }
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
                // For each branch of return, pop the function from stack
                return finalize(s)
            } else if name[.commutative] {
                // Try simplifying in the reserve order if the function is commutative
                if copy.count > 2 {
                    let after = try Function.simplifyCommutatively(copy.elements, by: name)
                    let s = after.complexity < copy.complexity ? after : copy
                    return finalize(s)
                }
            }

            // Cannot be further simplified
            return finalize(copy)
        } catch let e as KelvinError {
            Program.shared.curStackSize = 0
            throw ExecutionError.onNode(self, err: e)
        }
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
        // Base case.
        if nodes.count == 2 {
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

    public func equals(_ node: Node) -> Bool {
        if let fun = node as? Function {
            if fun.name == name {
                return equals(list: fun)
            }
        }
        return false
    }
    
    public func copy() -> Self {
        Self.init(name, elements.map { $0.copy() })
    }
    
    public var precedence: Keyword.Precedence { keyword?.precedence ?? .node }
    public var stringified: String { toString() }
    public var ansiColored: String { toString(colored: true) }

    private func parenthesize(_ s: String, _ colored: Bool) -> String {
        return colored ? "(".bold + s + ")".bold : "(\(s))"
    }
    
    private func toString(colored: Bool = false) -> String {
        let r = elements.map { colored ? $0.ansiColored : $0.stringified }
        let color: (String) -> String = {
            colored && Operation.registered[$0] != nil ? $0.bold.italic : $0
        }
        var n = " \(color(name)) "
        
        func formatted() -> String {
            let l = r.reduce(nil) {
                $0 == nil ? "\($1)" : "\($0!), \($1)"
            }
            return "\(color(name))\(parenthesize(l ?? "", colored))"
        }
        
        if let keyword = self.keyword {
            
            // Determine which form of the function to use;
            // there are three options: shorthand, operator, or default.
            let k = keyword.formatted
            let n = colored ? (k.replacingOccurrences(of: " ", with: "").isAlphanumeric ? k.bold : k) : k
            
            switch keyword.associativity {
            case .infix where count == 1:
                
                // Handle special case of -x.
                let c = keyword.operator?.name ?? (color(name))
                return "\(c)\(r[0])"
            case .infix where count == 2 || isCommutative:
                if let s = r.enumerated().reduce(nil, {
                    (a, c) -> String in
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

    /// Whether the child node should be enveloped in parenthesis when printing.
    /// If the parent and the child are both commutative and have the same name,
    /// then the parenthesis for the child is omitted; otherwise if the child's
    /// precedence is larger than that of the parent, the parenthesis is also omitted.
    ///
    /// - Note: Parentheses only apply to infix operations.
    /// - Parameter idx: The index of the child.
    /// - Returns: Whether a parenthesis should be used for the child when printing.
    private func usesParenthesis(forNodeAtIndex idx: Int) -> Bool {
        let child = elements[idx]
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
}
