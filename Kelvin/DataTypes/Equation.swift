//
//  Equation.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/9/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Equation: BinaryNode, NaN {
    
    public var stringified: String {
        return "\(lhs.stringified) \(mode.rawValue) \(rhs.stringified)"
    }
    
    public var ansiColored: String {
        return "\(lhs.ansiColored) \(mode.rawValue.bold) \(rhs.ansiColored)"
    }
    
    public var precedence: Keyword.Precedence {
        return .equation
    }

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

    public func simplify() throws -> Node {
        var eq = self

        // Simplify left and right side.
        eq.lhs = try lhs.simplify()
        eq.rhs = try rhs.simplify()

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
    public func define() throws {
        if mode != .equals {
            // Only an equality can be used for definition.
            let msg = "inequality '\(mode)' cannot be used for definition"
            throw ExecutionError.general(errMsg: msg)
        }

        guard let fun = lhs as? Function else {

            // If lhs is a var, then rhs is assigned as its definition.
            if let v = lhs as? Variable {

                // By calling rhs.simplify(), the following behavior is ensured:
                // Suppose the statement "define a = f(x)".
                // When the statement is executed, the value of "f(x)" instead of "f(x) is returned.
                let def = try rhs.simplify()
                
                // Check if variable is used within its own initial value
                // to prevent circular definition.
                if def.contains(where: {$0 === v}, depth: Int.max) {
                    throw ExecutionError.general(errMsg: "circular definition")
                }
                Variable.define(v.name, def)
                return
            }
            
            let msg = "left hand side of definition must be a variable/function"
            throw ExecutionError.general(errMsg: msg)
        }
        
        // Use the rhs of the equation as a template to create function definition.
        try fun.implement(using: rhs)
    }

    /**
     Swap left hand side and right and side of the equation
     e.g. a+b=c -> c=a+b
     
     - Returns: The equation with lhs and rhs swapped.
     */
    func reversed() -> Equation {
        return Equation(lhs: rhs, rhs: lhs)
    }

    /// Two equations are considered as identical if their operands are identical
    /// either in the forward direction or backward direction
    public func equals(_ node: Node) -> Bool {
        if let eq = node as? Equation {
            return equals(list: eq) || reversed().equals(list: eq)
        }
        return false
    }
}