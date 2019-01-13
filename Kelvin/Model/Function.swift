//
//  Function.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Function: Node {
    
    public var evaluated: Value? {
        return invoke()?.evaluated
    }
    
    /// Complexity of the function is the complexity of the List of args + 1.
    public var complexity: Int {
        return args.complexity + 1
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
    
    /**
     Whether the child node should be enveloped in parenthesis when printing.
     If the parent and the child are both commutative and have the same name,
     then the parenthesis for the child is omitted; otherwise if the child's
     priority is larger than that of the parent, the parenthesis is also omitted.
     
     - Note: Parentheses only apply to infix operations.
     - Parameter child: A child node of this function
     - Returns: Whether a parenthesis should be used for the child when printing.
     */
    private func usesParenthesis(for child: Node) -> Bool {
        if let fun = child as? Function {
            if let p1 = fun.syntax?.operator.priority {
                if let p2 = syntax?.operator.priority {
                    if p1 < p2 {
                        return true
                    } else if p1 == p2 {
                        let isCommutative = Operation.hasFlag(name, .isCommutative)
                        return !isCommutative || name != fun.name
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
        
        // Simplify each argument, if requested.
        if !Operation.hasFlag(name, .preservesArguments) {
            copy.args = copy.args.simplify() as! List
        }
        
        // If the function is commutative, then try simplifying in reverse order as well.
        if Operation.hasFlag(name, .isCommutative) {
            if let s = copy.invoke()?.simplify() {
                return s
            } else {
                let elements = copy.args.elements.reversed()
                copy.args = List(Array(elements))
            }
        }
        
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
     Unravel the binary operation tree.
     e.g. +(d,+(+(a,b),c)) becomes +(a,b,c,d)
     
     - Warning: Before invoking this function, the expression should be in addtion only form.
                Under normal circumstances, don't use this function.
     */
    public func flatten() -> Function {
        var copy = arguments{($0 as? Function)?.flatten() ?? $0} // Initial recursive call
        
        // Flatten commutative operations
        if Operation.hasFlag(copy.name, .isCommutative) {
            var newArgs = [Node]()
            copy.args.elements.forEach {arg in
                if let fun = arg as? Function, fun.name == copy.name {
                    newArgs.append(contentsOf: fun.args.elements)
                } else {
                    newArgs.append(arg)
                }
            }
            copy.args.elements = newArgs
        }
        
        return copy
    }
    
    /// Functions are equal to each other if their name and arguments are the same
    /// Commutative functions are equal to each other if they have the same elements -
    /// that is, regardless of the order they are in.
    public func equals(_ node: Node) -> Bool {
        if let fun = node as? Function {
            if fun.name == name {
                if Operation.hasFlag(name, .isCommutative) {
                    return fun.args === args
                }
                return List.strictlyEquals(args, fun.args)
            }
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
