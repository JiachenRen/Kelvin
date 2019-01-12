//
//  Function.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

typealias Definition = ([Node]) -> Node?

public struct Function: Node {
    
    public var evaluated: Value? {
        return invoke()?.evaluated
    }
    
    /// The name of the function
    var name: String {
        didSet {
            // Update the definition of the function if the name changes.
            resolveDefinition()
        }
    }
    
    /// List of arguments that the function takes in.
    /// - Note: When the arguments change, the signature of the function
    /// also changes, potentially resulting in a different definition!
    var args: List {
        didSet {
            // Update the definition of the function because the signature changed!
            resolveDefinition()
        }
    }
    
    /// The operation that contains the definition of the function
    /// - Note: An operation only exists when the arguments match the requirements
    var operation: Operation?
    
    /// The syntax of the function (derived from just the name)
    var syntax: Syntax? {
        return Operation.getSyntax(for: name)
    }
    
    public var description: String {
        let r = args.elements
        let n = name
        
        func formatted() -> String  {
            let l = r.map{$0.description}.reduce(nil) {
                $0 == nil ? "\($1)": "\($0!), \($1)"
            }
            return "\(name)(\(l ?? ""))"
        }
        
        if let position = self.syntax?.operator.position {
            switch position {
            case .infix:
                if let s = r.reduce(nil, {(a, b) -> String in
                    let p = usesParenthesis(for: b)
                    let b1 = p ? "(\(b))" : "\(b)"
                    return a == nil ? "\(b1)" : "\(a!) \(n) \(b1)"
                }) {
                    return "\(s)"
                } else {
                    return ""
                }
            case .prefix where r.count == 1:
                let p = usesParenthesis(for: r[0])
                return p ? "\(n) (\(r[0]))" : "\(n) \(r[0])"
            default:
                break
            }
        }
        
        return formatted()
    }
    
    /// Whether the target node should be enveloped in parenthesis when printing.
    private func usesParenthesis(for node: Node) -> Bool {
        if let fun = node as? Function {
            if let p1 = fun.syntax?.operator.priority {
                if let p2 = syntax?.operator.priority {
                    if p1 < p2 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    init(_ name: String, _ args: List) {
        self.name = name
        self.args = args
        
        resolveDefinition()
    }
    
    init(_ name: String, _ args: [Node]) {
        self.init(name, List(args))
    }
    
    /**
     Resolve the definition of the function. There are three types of definitions:
     - binary: Pre-defined operations such as +, -, *, /
     - unary: Pre-defined operations such as log, negate, etc.
     - custom: user defined operations, such as a function f(x)
     */
    private mutating func resolveDefinition() {
        
        // Match function with registered operations
        if let op = Operation.resolve(name, args: args.elements) {
            self.operation = op
        }
        
    }
    
    /// Performs the operation defined by the function on the arguments.
    func invoke() -> Node? {
        return operation?.def(args.elements)
    }
    
    /**
     Simplify each argument, if possible, then perform the operation defined by this
     function on the arguments, if possible. Otherwise, a copy of the original function
     is returned, with each argument simplified.
     
     - Returns: a node representing the simplified(computed) value of the function.
     */
    public func simplify() -> Node {
        
        // Make a copy of self.
        var copy = self
        
        // If the function's name begins with "$", the compiler to preserves it once
        // This enables functions to be used as an input type.
        // Suppose we have "repeat(random(), 5)", it only execute random 1 once
        // and copy the value 5 times to create the list, say {0.1, 0.1, 0.1, 0.1, 0.1};
        // Now if we change it to "repeat($random(),5), it will behave as what you would expect:
        // a list of 5 random numbers.
        if name.starts(with: "$") {
            var name = self.name
            name.removeFirst()
            return Function(name, args)
        }
        
        // First simplify each argument, if possible.
        copy.args = copy.args.simplify() as! List
        
        // If the operation can be performed on the given arguments, perform the operation.
        // Then, the result of the operation is simplified;
        // otherwise returns a copy of the original function with each argument simplified.
        return copy.invoke()?.simplify() ?? copy
    }
    
    /**
     Perform batch operation on the list of arguments.
     
     - Parameter action: The action to be performed on the argument list.
     - Returns: A new function with action performed on each argument
     */
    func arguments(do action: Unary) -> Function {
        var copy = self
        copy.args = action(copy.args) as! List
        return copy
    }
    
    /**
     Convert the expression to addition only form.
     i.e. -(a,b)      -> +(a,negate(b))
          -(-(a,b),c) -> +(+(a,negate(b)),negate(c))
          -(a,-(b,c)) -> +(a,negate(+(b,negate(c))))
     
     - Returns: The additional form of the original expression
     */
    public func toAdditionOnlyForm() -> Node {
        var copy = arguments{$0.toAdditionOnlyForm()}
        if copy.name == "-" {
            if args.elements.count == 2 {
                // Change subtraction to addition
                copy.name = "+"
                let rhs = copy.args[1]
                let negated = Function("negate", [rhs])
                copy.args[1] = negated
            } else {
                copy.name = "negate"
            }
            return copy
        }
        return copy
    }
    
    /**
     Convert all divisions to exponential form.
     e.g. a/b becomes a*b^(-1)
     
     - Returns: The exponential form of the original expression
     */
    public func toExponentialForm() -> Node {
        var copy = arguments{$0.toExponentialForm()}
        if copy.name == "/" {
            assert(copy.args.elements.count == 2)
            // Change division to multiplication
            copy.name = "*"
            let rhs = copy.args[1]
            copy.args[1] = Function("^", [rhs, -1])
        }
        return copy
    }
    
    /**
     Unravel the binary operation tree.
     e.g. +(d,+(+(a,b),c)) becomes +(a,b,c,d)
     
     - Warning: Before invoking this function, the expression should be in addtion only form.
                Under normal circumstances, don't use this function.
     */
    public func flatten() -> Node {
        var copy = arguments{$0.flatten()} // Initial recursive call
        switch copy.name {
        case "negate":
            assert(copy.args.elements.count == 1)
            let nested = copy.args[0]
            if var fun = nested as? Function {
                if fun.name == "negate" {
                    return fun.args[0]
                } else if fun.name == "+" {
                    fun.args.elements = fun.args.elements
                        .map{Function("negate", [$0])}
                    return fun.flatten()
                }
            }
        case "+", "*":
            var newArgs = [Node]()
            copy.args.elements.forEach {arg in
                if let fun = arg as? Function, fun.name == copy.name {
                    newArgs.append(contentsOf: fun.args.elements)
                } else {
                    newArgs.append(arg)
                }
            }
            copy.args.elements = newArgs
        default: break
        }
        return copy
    }
    
    /// Functions are equal to each other if their name and arguments are the same
    public func equals(_ node: Node) -> Bool {
        if let fun = node as? Function {
            return fun.name == name && List.strictlyEquals(args, fun.args)
        }
        return false
    }
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
                            ignores it) and returns a node as replacement.
     */
    public func replacing(by replace: Unary, where predicament: (Node) -> Bool) -> Node {
        var copy = self
        copy.args.elements = copy.args.elements.map{
            $0.replacing(by: replace, where: predicament)
        }
        return predicament(copy) ? replace(copy) : copy
    }
}
