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
    var numericalVal: Double? {
        return invoke()?.numericalVal
    }
    
    /// The name of the function
    var name: String
    
    /// List of arguments that the function takes in
    var args: List
    
    /// The definition of the function.
    var def: Definition?
    
    var description: String {
        return "\(name)(\(List(args)))"
    }
    
    init(_ name: String, _ args: List) throws {
        self.name = name
        self.args = args
        try resolveDefinition()
    }
    
    init(_ name: String, _ args: [Node]) throws {
        try self.init(name, List(args))
    }
    
    private mutating func resolveDefinition() throws {
        if let b = BinOperation.registered[name] {
            def = {nodes in
                let values = nodes.map{$0.numericalVal}
                if values.contains(nil) {return nil}
                var u = values.map{$0!}
                let r: Double = u.removeFirst()
                return u.reduce(r){b.bin($0,$1)}
            }
        } else if let u = UnaryOperation.registered[name] {
            if args.elements.count != 1 {
                let msg = "incorrect number of arguments, \(args.elements.count) found, 1 expected"
                throw CompilerError.illegalArgument(errMsg: msg)
            }
            def = {nodes in
                if let n = nodes[0].numericalVal {
                    return u(n)
                }
                return nil
            }
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
        
        // First simplify each argument, if possible.
        copy.args = copy.args.simplify() as! List
        
        // If the operation can be performed on the given arguments, then perform the operation,
        // otherwise returns a copy of the original function with each argument simplified.
        return copy.invoke() ?? copy
    }
    
    /**
     Perform batch operation on the list of arguments.
     
     - Parameter action: The action to be performed on the argument list.
     - Returns: A new function with action performed on each argument
     */
    func arguments(do action: (Node) -> Node) -> Function {
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
            assert(copy.args.elements.count == 2)
            // Change subtraction to addition
            copy.name = "+"
            let rhs = copy.args.elements[1]
            do {
                let negated = try Function("negate", [rhs])
                copy.args.elements[1] = negated
                return copy
            } catch let e {
                debugPrint("An unexpected error \"\(e)\"has occurred.")
                fatalError()
            }
        }
        return copy
    }
    
    // TODO
    func toExponentialForm() -> Node {
        return arguments{$0.toExponentialForm()}
    }
    
    /**
     Unravel the binary operation tree.
     e.g. +(d,+(+(a,b),c)) becomes +(a,b,c,d)
     
     - Warning: Before invoking this function, the expression should be in addtion only form.
     */
    func flatten() -> Node {
        var copy = arguments{$0.flatten()} // Initial recursive call
        if copy.name == "negate" {
            assert(copy.args.elements.count == 1)
            let nested = copy.args.elements[0]
            if var fun = nested as? Function {
                if fun.name == "negate" {
                    return fun.args.elements[0]
                } else if fun.name == "+" {
                    fun.args.elements = fun.args.elements
                        .map{try! Function("negate", [$0])}
                    return fun.flatten()
                }
            }
        } else if copy.name == "+" {
            var newArgs = [Node]()
            copy.args.elements.forEach {arg in
                if let fun = arg as? Function, fun.name == "+" {
                    newArgs.append(contentsOf: fun.args.elements)
                } else {
                    newArgs.append(arg)
                }
            }
            copy.args.elements = newArgs
        }
        return copy
    }
}
