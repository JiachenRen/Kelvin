//
//  Syntax.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/13/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/**
 This is the syntax of the operations.
 For the function with signature "define(f(x)=x^2)",
 the prefix syntax is "define f(x)=x^2".
 
 The infix syntax, on the other hand, only applies to
 functions that take in two arguments.
 e.g. the function "and(a,b)" can be invoked with "a and b"
 */
public struct Syntax {
    
    enum Position {
        case prefix
        case infix
        case postfix
    }
    
    /// The shorthand for the operation.
    /// e.g. && for "and", and || for "or"
    var shorthand: String?
    
    /// A single character that represents the operation.
    var `operator`: Operator
    
    struct Operator: CustomStringConvertible {
        
        /// The syntactic position of the operator, either prefix, postfic, or infix
        var position: Position
        
        /// The priority of the operator
        var priority: Priority
        
        /// A single character is used to represent the operation;
        /// By doing so, the compiler can treat the operation like +,-,*,/, and so on.
        var code: Character
        
        var description: String {
            return "\(code)"
        }
        
        init(_ position: Position, _ priority: Priority, _ code: Character) {
            self.position = position
            self.priority = priority
            self.code = code
        }
    }
    
    /// A unicode scalar value that would never interfere with input
    /// In this case, the scalar value (and the ones after)
    /// does not have any unicode counterparts
    static var scalar = 60000
    
    /// A dictionary that automatically keeps track of operators.
    static var operators = [Character: Operator]()
    
    init(_ position: Position, priority: Priority = .execution, shorthand: String? = nil, operator: Character? = nil) {
        
        self.shorthand = shorthand
        
        // Assign a unique operator to the operation consisting of
        // a single character that does not exist in any language.
        let code = `operator` ?? Character(UnicodeScalar(Syntax.scalar)!)
        self.operator = Operator(position, priority, code)
        
        
        // Make sure the operator is currently undefined
        assert(Syntax.operators[code] == nil)
        
        // Register the operator
        Syntax.operators[code] = self.operator
        
        // Increment the scalar so that each operator is unique.
        Syntax.scalar += 1
    }
}
