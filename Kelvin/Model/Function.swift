//
//  Function.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

typealias Definition = ([Node]) -> Node?

struct Function: Node {
    
    /// The format of the function when represented as text
    enum Format {
        case binary
        case unary
        case function
        case prefix
        case infix
    }
    
    var evaluated: Value? {
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
    
    /// The definition of the function.
    var def: Definition?
    
    /// The format of the function when represented as text
    var format: Format
    
    var description: String {
        let r = args.elements
        let n = name
        switch format {
        case .binary:
            var a = r.map{$0.description}
                .reduce(""){"\($0)\(n)\($1)"}
            if a.count > 0 {
                a.removeFirst()
            }
            return "(\(a))"
        case .infix where r.count == 2:
            return "(\(r[0]) \(n) \(r[1]))"
        case .prefix where r.count == 1:
            return "\(n) \(r[0])"
        case .unary where n == "negate":
            return "(-\(r[0]))"
        case .function:
            fallthrough
        default:
            var l = r.map{$0.description}
                .reduce(""){"\($0),\($1)"}
            if l.count > 0 {
                l.removeFirst()
            }
            return "\(name)(\(l))"
        }
    }
    
    init(_ name: String, _ args: List) {
        self.name = name
        self.args = args
        self.format = .function
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
        if let b = BinaryOperation.registered[name] {
            // Resolve registered binary operations
            def = {nodes in
                let values = nodes.map{$0.evaluated}
                if values.contains(where: {$0 == nil}) {return nil}
                var u = values.map{$0!}
                let r: Double = u.removeFirst()
                    .doubleValue()
                return u.reduce(r){
                    (try? b.bin($0.doubleValue(),$1.doubleValue())) ?? .nan
                }
            }
            
        } else if let u = UnaryOperation.registered[name], args.elements.count == 1 {
            // Resolve registered unary operations
            def = {nodes in
                if let n = nodes[0].evaluated {
                    return (try? u(n.doubleValue())) ?? .nan
                }
                return nil
            }
            
        } else {
            // Resolve registered parametric operations
            if let parOp = ParametricOperation.resolve(name, args: args.elements) {
                def = parOp.def
            }
        }
        
        // Extract parametric operations with the matching syntax requirements
        func extract(_ position: ParametricOperation.SyntacticSugar.Position) -> [String] {
            return ParametricOperation.registered
                .filter{$0.syntacticSugar?.position == position}
                .map{$0.name}
        }
        
        let infixes = extract(.infix)
        let prefixes = extract(.prefix)
        let unary = UnaryOperation.registered.keys
        let binary = BinaryOperation.registered.keys
        
        if infixes.contains(name) {
            format = .infix
        } else if prefixes.contains(name) {
            format = .prefix
        } else if unary.contains(name) {
            format = .unary
        } else if binary.contains(name) {
            format = .binary
        }
    }
    
    /// Performs the operation defined by the function on the arguments.
    func invoke() -> Node? {
        return def?(args.elements)
    }
    
    /**
     Simplify each argument, if possible, then perform the operation defined by this
     function on the arguments, if possible. Otherwise, a copy of the original function
     is returned, with each argument simplified.
     
     - Returns: a node representing the simplified(computed) value of the function.
     */
    func simplify() -> Node {
        
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
    func toAdditionOnlyForm() -> Node {
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
    func toExponentialForm() -> Node {
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
    func flatten() -> Node {
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
    func equals(_ node: Node) -> Bool {
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
    func replacing(by replace: Unary, where predicament: (Node) -> Bool) -> Node {
        var copy = self
        copy.args.elements = copy.args.elements.map{
            $0.replacing(by: replace, where: predicament)
        }
        return predicament(copy) ? replace(copy) : copy
    }
}
