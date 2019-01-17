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
        let encoding = Encoder.next()
        
        // Make sure the operator is currently undefined and the name is available
        assert(Syntax.lexicon[encoding] == nil)
        assert(glossary[commonName] == nil)
        
        // Create the syntax
        let syntax = Syntax(encoding, commonName, position, priority: priority, operator: `operator`)
        
        // Register in encoding lexicon and common name glossary
        lexicon[encoding] = syntax
        glossary[commonName] = syntax
    }
    
    /// Reset to syntactic definitions for operations.
    public static func restoreDefault() {
        
        // Clear glossary, lexicon, and reset encoder scalar before proceeding.
        lexicon = [Encoding: Syntax]()
        glossary = [String: Syntax]()
        Encoder.reset()
        
        // Definitions
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
    
    public class Encoder {
        
        /// A unicode scalar value that would never interfere with input
        /// In this case, the scalar value (and the ones after)
        /// does not have any unicode counterparts
        private static var scalar = 60000
        
        /// Reset the scalar
        fileprivate static func reset() {
            scalar = 60000
        }
        
        /// Generate next available encoding from a unique scalar.
        public static func next() -> Character {
            
            // Assign a unique code to the operation consisting of
            // an unused unicode
            let encoding = Character(UnicodeScalar(scalar)!)
            
            // Increment the scalar so that each operator is unique.
            scalar += 1
            
            return encoding
        }
    }
    
    public enum Position {
        case prefix
        case infix
        case postfix
    }
    
    public enum Priority: Int, Comparable {
        case execution = 1  // ;, >>
        case definition     // :=
        case `repeat`       // repeat
        case equation       // =
        case or             // ||
        case and            // &&
        case equality       // ==, <, >, <=, >=
        case addition       // +,-
        case product        // *,/
        case exponent       // ^
        
        public static func < (lhs: Priority, rhs: Priority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
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
