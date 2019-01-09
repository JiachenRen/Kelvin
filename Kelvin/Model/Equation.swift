//
//  Equation.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/9/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

struct Equation: Node, NaN {
    
    /// The left hand side of the equation
    var lhs: Node
    
    /// The right hand side of the equation
    var rhs: Node
    
    /// TODO: Implement inequality
    init(lhs: Node, rhs: Node) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
    func simplify() -> Node {
        var eq = self
        
        // Simplify left and right side.
        eq.lhs = lhs.simplify()
        eq.rhs = rhs.simplify()
        
        // After simplification, lhs = rhs, equation is always true.
        if eq.lhs.equals(eq.rhs) {
            return true
        }
        
        // If lhs and rhs comes down to a number, compare their numerical values.
        if let v1 = eq.lhs.evaluated, let v2 = eq.rhs.evaluated {
            // TODO: Implement tolerance?
            return v1.equals(v2)
        }
        
        // If nothing could be done, then return a copy of self
        return eq
    }
    
    // TODO: Implement
    func solve() -> Node? {
        return nil
    }
    
    /// Perform an action on both sides of the equation
    private func perform(_ action: Unary) -> Node {
        var eq = self
        eq.lhs = action(lhs)
        eq.rhs = action(rhs)
        return eq
    }
    
    func toAdditionOnlyForm() -> Node {
        return perform{$0.toAdditionOnlyForm()}
    }
    
    func toExponentialForm() -> Node {
        return perform{$0.toExponentialForm()}
    }
    
    func flatten() -> Node {
        return perform{$0.flatten()}
    }
    
    func equals(_ node: Node) -> Bool {
        if let eq = node as? Equation {
            return lhs.equals(eq.lhs) && rhs.equals(eq.rhs)
        }
        return false
    }
    
    var description: String {
        return "\(lhs)=\(rhs)"
    }
    
}
