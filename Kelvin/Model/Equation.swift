//
//  Equation.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/9/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Equation: Node, NaN {
    
    /// The left hand side of the equation
    var lhs: Node
    
    /// The right hand side of the equation
    var rhs: Node
    
    enum Mode: String {
        case greaterThan = ">"
        case greaterThanOrEquals = ">="
        case lessThan = "<"
        case lessThanOrEquals = "<="
        case equals = "="
    }
    
    /// The mode of the equation
    var mode: Mode
    
    /// TODO: Implement inequality
    init(lhs: Node, rhs: Node, mode: Mode = .equals) {
        self.mode = mode
        self.lhs = lhs
        self.rhs = rhs
    }
    
    public func simplify() -> Node {
        var eq = self
        
        // Simplify left and right side.
        eq.lhs = lhs.simplify()
        eq.rhs = rhs.simplify()
        
        // After simplification, lhs = rhs, equation is always true.
        if mode.rawValue.contains("=") && eq.lhs === eq.rhs {
            return true
        }
        
        // If lhs and rhs comes down to a number, compare their numerical values.
        if let v1 = eq.lhs.evaluated, let v2 = eq.rhs.evaluated {
            // TODO: Implement tolerance?
            let d1 = v1.doubleValue
            let d2 = v2.doubleValue
            
            if d1 != .nan && d2 != .nan {
                switch mode {
                case .equals:
                    return d1 == d2
                case .greaterThanOrEquals:
                    return d1 >= d2
                case .lessThanOrEquals:
                    return d1 <= d2
                case .lessThan:
                    return d1 < d2
                case .greaterThan:
                    return d1 > d2
                }
            }
        }
        
        // If nothing could be done, then return a copy of self
        return eq
    }
    
    // TODO: Implement
    func solve() -> Node? {
        return nil
    }
    
    /**
     Assign the value of rhs to lhs. If lhs is a function, a new Operation is defined
     using lhs as signature and rhs as definition. On the other hand; if lhs is a variable,
     then rhs is assigned to the variable as definition.
     
     - Returns: An error if the definition is unsuccessful.
     */
    func define() -> Node? {
        if mode != .equals {
            // Only an equality can be used for definition.
            return "inequality '\(mode)' cannot be used for definition"
        }
        
        guard let fun = lhs as? Function else {
            
            // If lhs is a var, then rhs is assigned as its definition.
            if let v = lhs as? Variable {
                
                // By calling rhs.simplify(), the following behavior is ensured:
                // Suppose the statement "define a = f(x)".
                // When the statement is executed, the value of "f(x)" instead of "f(x) is returned.
                Variable.define(v.name, rhs.simplify())
            }
            
            return nil
        }
        
        let args = fun.args.elements
        
        // Check to make sure that every argument is a variable
        for arg in args {
            if !(arg is Variable) {
                return "error: function signature should only contain variables"
            }
        }
        
        // Cast the arguments to variables
        let vars = args.map{$0 as! Variable}
        
        // Create function signature
        let signature = [Operation.ArgumentType](repeating: .any, count: vars.count)
        var dict = [String: Int]()
        vars.enumerated().forEach{(args) in
            let (idx, v) = args
            dict[v.name] = idx
        }
        
        // Make sure the old definition is removed from registry
        Operation.remove(fun.name, signature)
        
        // Create a definition template from right hand side, then
        // replace the variables in template with arguments as input
        // to create the definition
        let def: Definition = { args in
            var template = self.rhs.replacing(by: {
                var rpl = $0 as! Variable
                
                // This is for dealing with the following bug:
                // Suppose we have f(a,b) = a+b^2
                // Call to f(a,b) results in a+b^2,
                // Nevertheless, call to f(b,a) results in b+b^2!
                rpl.name = "#\(rpl.name)"
                return rpl
            }, where: {$0 is Variable})
            
            dict.forEach{(pair) in
                let (key, value) = pair
                template = template.replacing(by: {_ in args[value]}){
                    ($0 as? Variable)?.name == "#\(key)"
                }
            }
            
            // Revert changes made to the variable names
            return template.replacing(by: {
                var mod = $0 as! Variable
                mod.name.removeFirst()
                return mod
            }, where: {($0 as? Variable)?.name.starts(with: "#") ?? false})
                // Say f(x) = g(x), this ensures that g(x) is evaluated
                .simplify()
        }
        
        // Create parametric operation
        let op = Operation(fun.name, signature, definition: def)
        
        // Register parametric operation
        Operation.register(op)
        
        return nil
    }
    
    /// Perform an action on both sides of the equation
    private func perform(_ action: Unary) -> Node {
        var eq = self
        eq.lhs = action(lhs)
        eq.rhs = action(rhs)
        return eq
    }
    
    public func toAdditionOnlyForm() -> Node {
        return perform{$0.toAdditionOnlyForm()}
    }
    
    public func toExponentialForm() -> Node {
        return perform{$0.toExponentialForm()}
    }
    
    public func flatten() -> Node {
        return perform{$0.flatten()}
    }
    
    /**
     Swap left hand side and right and side of the equation
     e.g. a+b=c -> c=a+b
     
     - Returns: The equation with lhs and rhs swapped.
     */
    func reversed() -> Node {
        return Equation(lhs: rhs, rhs: lhs)
    }
    
    /// Two equations are considered as identical if their operands are identical
    /// either in the forward direction or backward directino
    public func equals(_ node: Node) -> Bool {
        if let eq = node as? Equation {
            let forwardEquals = lhs === eq.lhs && rhs === eq.rhs
            let backwardEquals = lhs === eq.rhs && rhs === eq.lhs
            return forwardEquals || backwardEquals
        }
        return false
    }
    
    public var description: String {
        return "\(lhs) \(mode.rawValue) \(rhs)"
    }
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
     ignores it) and returns a node as replacement.
     */
    public func replacing(by replace: Unary, where predicament: (Node) -> Bool) -> Node {
        var copy = self
        copy.lhs = lhs.replacing(by: replace, where: predicament)
        copy.rhs = rhs.replacing(by: replace, where: predicament)
        return predicament(copy) ? replace(copy) : copy
    }
    
}
