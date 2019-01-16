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
    
    public typealias Encoding = Character
    
    /// The custom operator for a function. For example,
    /// the syntax component of function "mod" could have an operator of "%"
    var `operator`: Operator?
    
    /// The syntactic position of the operator, either prefix, postfic, or infix
    var position: Position
    
    /// The priority of the operator
    var priority: Priority
    
    /// The name of the function that the syntax applies to
    var commonName: String
    
    /// A dictionary that maps an encoding to a syntax component.
    public static var lexicon = [Encoding: Syntax]()
    
    /// A dictionary that maps a common name to a syntax component.
    public static var glossary = [String: Syntax]()
    
    /// A single character is used to encode the operation;
    /// By doing so, the compiler can treat the operation like +,-,*,/, and so on.
    var encoding: Encoding
    
    /// A unicode scalar value that would never interfere with input
    /// In this case, the scalar value (and the ones after)
    /// does not have any unicode counterparts
    private static var scalar = 60000
    
    /// Syntax w/ higher compilation priority are compiled first.
    /// The longer the name of the operator, the higher the compilation priority.
    var compilationPriority: Int  {
        return self.operator?.name.count ?? 0
    }
    
    // Function name properly formatted w/ syntax.
    var formatted: String {
        if let o = self.operator {
            switch o.padding {
            case .bothSides:
                return " \(o) "
            case .leftSide:
                return " \(o)"
            case .rightSide:
                return "\(o) "
            case .none:
                return "\(o)"
            }
        }
        
        switch position {
        case .infix:
            return " \(commonName) "
        case .prefix:
            return "\(commonName) "
        case .postfix:
            return " \(commonName)"
        }
    }
    
    private init(_ code: Encoding, _ commonName: String, _ position: Position, priority: Priority, operator: Operator?) {
        self.commonName = commonName
        self.position = position
        self.encoding = code
        self.priority = priority
        self.operator = `operator`
    }
    
    public static func define(for commonName: String, _ position: Position, priority: Priority = .execution, operator: Operator? = nil) {
        
        // Assign a unique code to the operation consisting of
        // an unused unicode
        let encoding = Character(UnicodeScalar(Syntax.scalar)!)
        
        // Make sure the operator is currently undefined
        assert(Syntax.lexicon[encoding] == nil)
        
        // Make sure the name is available
        assert(glossary[commonName] == nil)
        
        // Create the syntax
        let syntax = Syntax(encoding, commonName, position, priority: priority, operator: `operator`)
        
        // Register in encoding lexicon
        lexicon[encoding] = syntax
        
        // Register in common name glossary
        glossary[commonName] = syntax
        
        // Increment the scalar so that each operator is unique.
        Syntax.scalar += 1
    }
    
    public static func createDefinitions() {
        define(for: "+", .infix, priority: .addition, operator: .init("+"))
        define(for: "-", .infix, priority: .addition, operator: .init("-"))
        define(for: "*", .infix, priority: .product, operator: .init("*"))
        define(for: "/", .infix, priority: .product, operator: .init("/"))
        define(for: "mod", .infix, priority: .product, operator: .init("%"))
        define(for: "^", .infix, priority: .exponent, operator: .init("^"))
        define(for: "sqrt", .prefix, priority: .exponent, operator: .init("√", padding: .none))
        define(for: "degrees", .postfix, priority: .exponent, operator: .init("°", padding: .none))
        define(for: "factorial", .postfix, priority: .exponent, operator: .init("!", padding: .none))
        define(for: "pct", .postfix, priority: .exponent)
        define(for: "=", .infix, priority: .equation, operator: .init("="))
        define(for: "<", .infix, priority: .equality, operator: .init("<"))
        define(for: ">", .infix, priority: .equality, operator: .init(">"))
        define(for: ">=", .infix, priority: .equality, operator: .init(">="))
        define(for: "<=", .infix, priority: .equality, operator: .init("<="))
        define(for: "equals", .infix, priority: .equality, operator: .init("=="))
        define(for: "and", .infix, priority: .and, operator: .init("&&"))
        define(for: "or", .infix, priority: .or, operator: .init("||"))
        define(for: "define", .infix, priority: .definition, operator: .init(":=", padding: .none))
        define(for: "def", .prefix, priority: .definition)
        define(for: "del", .prefix)
        define(for: "get", .infix)
        define(for: "size", .prefix)
        define(for: "map", .infix, operator: .init("|"))
        define(for: "then", .infix, operator: .init(";", padding: .rightSide))
        define(for: "feed", .infix, operator: .init("->"))
        define(for: "repeat", .infix, priority: .repeat, operator: .init("...", padding: .none))
        define(for: "copy", .infix, priority: .repeat)
        define(for: "complexity", .prefix)
        define(for: "round", .prefix, priority: .exponent)
        define(for: "eval", .prefix)
        define(for: "print", .prefix)
        define(for: "println", .prefix)
    }
    
    public enum Position {
        case prefix
        case infix
        case postfix
    }
    
    public struct Operator: CustomStringConvertible {
        
        /// The padding for the operator when printing
        enum Padding {
            
            /// A space is added to the left
            case leftSide
            
            /// A space is added to the right
            case rightSide
            
            /// No space added
            case none
            
            /// The operator is padded with space on both sides.
            case bothSides
        }
        
        /// The name of the operator, e.g. "+", "-".
        let name: String
        let padding: Padding
        
        init(_ name: String, padding: Padding = .bothSides) {
            self.name = name
            self.padding = padding
        }
        
        public var description: String {
            return name
        }
    }
}
