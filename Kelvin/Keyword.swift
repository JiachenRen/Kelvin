//
//  Keyword.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/13/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/**
 Keyword is used by the compiler to compile operations into their encodings,
 resolve operator precedence, associativity, etc.
 
 Infix associative property - applies to functions that take in two arguments.
 e.g. the function "and(a,b)" can be invoked with "a and b"
 Postfix/prefix associative property - applies to unary operations.
 */
public struct Keyword {

    public typealias Encoding = Character

    /// The custom operator for a keyword. For example,
    /// the infix keyword .mod could have an operator of "%"
    public var `operator`: Operator?

    /// The associative property of the operator, either prefix, postfix, or infix
    public var associativity: Associativity

    /// The precednece of the operator
    public var precedence: Precedence

    /// The name of the operation that the keyword is associated with.
    public var name: String

    /// A dictionary that maps an encoding to a keyword.
    public static var encodings: [Encoding: Keyword] = {
        defaultDefinitions.reduce(into: [:]) {
            $0[$1.encoding] = $1
        }
    }()

    /// A dictionary that maps the name of an operation to a keyword.
    public static var glossary: [String: Keyword] = {
        defaultDefinitions.reduce(into: [:]) {
            $0[$1.name] = $1
        }
    }()

    /// A single character is used to encode the operation;
    /// By doing so, the compiler can treat the operation like +,-,*,/, and so on.
    public var encoding: Encoding

    /// Keyword w/ higher compilation priority are compiled first.
    /// The longer the name of the operator, the higher the compilation priority.
    public var compilationPriority: Int {
        return self.operator?.name.count ?? 0
    }

    /// Properly formatted w/ keyword.
    public var formatted: String {
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

        switch associativity {
        case .infix:
            return " \(name) "
        case .prefix:
            return "\(name) "
        case .postfix:
            return " \(name)"
        }
    }

    fileprivate init(
        for name: String,
        associativity: Associativity,
        precedence: Precedence? = nil,
        operator: Operator? = nil
    ) {
        self.name = name
        self.associativity = associativity
        if let p = precedence {
            self.precedence = p
        } else {
            switch associativity {
            case .infix:
                self.precedence = .pipeline
            case .prefix:
                self.precedence = .prefix
            case .postfix:
                self.precedence = .postfix
            }
        }
        self.operator = `operator`
        self.encoding = Encoder.next() // Create a unique encoding
    }

    /// Adds a custom defined keyword to encodings and glossary collections.
    public static func define(
        for name: String,
        associativity: Associativity,
        precedence: Precedence? = nil,
        operator: Operator? = nil
    ) {

        // Create the keyword
        let keyword = Keyword(
            for: name,
            associativity: associativity,
            precedence: precedence,
            operator: `operator`)

        // Make sure the encoding is currently unassigned and the name is available
        assert(Keyword.encodings[keyword.encoding] == nil)
        assert(Keyword.glossary[name] == nil)

        // Register the keyword in glossary and encodings
        encodings[keyword.encoding] = keyword
        glossary[keyword.name] = keyword
        
        ambiguousOperators = findAmbiguousOperators()
    }
    
    /**
     Some operators have ambiguous definitions. i.e., they use the same
     operator, but have different associativity.
     e.g. '!', when used as a prefix, means .not while the same operator used
     as a postfix, say in 'a!', it means factorial.
     This function finds all ambiguous keyword operators.
     */
    public static var ambiguousOperators: [String: [Keyword]] = {
        return findAmbiguousOperators()
    }()
    
    private static func findAmbiguousOperators() -> [String: [Keyword]] {
        var dict = [String: [Keyword]]()
        var d = [String: [Associativity: Keyword]]()
        for keyword in encodings.values {
            if let o = keyword.operator?.name {
                if var p = d[o] {
                    let pos = keyword.associativity
                    if p[pos] != nil {
                        let msg = "duplicate definition for operator \(o) w/ associativity of \(pos)"
                        fatalError(msg)
                    } else {
                        p[pos] = keyword
                        
                        dict.updateValue(Array(p.values), forKey: o)
                        d.updateValue(p, forKey: o)
                    }
                    
                } else {
                    let m: [Associativity: Keyword] = [keyword.associativity: keyword]
                    d[o] = m
                }
            }
        }
        return dict
    }

    /// Reset to syntactic definitions for operations by
    /// First reset encoder scalar, then reload glossary and lexicon
    public static func restoreDefault() {
        encodings = defaultDefinitions.reduce(into: [:]) {
            $0[$1.encoding] = $1
        }
        glossary = defaultDefinitions.reduce(into: [:]) {
            $0[$1.name] = $1
        }
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

    public enum Associativity {
        case prefix
        case infix
        case postfix
    }

    public enum Precedence: Int, Comparable {
        case prefixCommand = 0  // return, throw, print, println, etc.
        case pipeline           // ->, ;
        case conditional        // ?
        case pair               // :
        case assignment         // :=, +=, -=, *=, /=
        case equation           // =
        case `repeat`           // ...
        case or                 // ||
        case nor                // !|
        case and                // &&
        case nand               // !&
        case xor                // ^^
        case equality           // ==, !=
        case relational         // <, >, <=, >=
        case concat             // &
        case addition           // +,-
        case scaling            // *,/
        case exponent           // ^
        case coersion           // as
        case derivative         // '
        case prefix             // √, !(not)
        case postfix            // ++, --, !(factorial), °, %
        case `subscript`        // ::
        case binding            // binding between closures
        case node               // leaf nodes should never require parenthesis

        public static func <(lhs: Precedence, rhs: Precedence) -> Bool {
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

    /// Default keywords
    private static let defaultDefinitions: [Keyword] = [
        
        // Arithmetic
        .init(for: .add, associativity: .infix, precedence: .addition, operator: .init("+")),
        .init(for: .sub, associativity: .infix, precedence: .addition, operator: .init("-")),
        .init(for: .negate, associativity: .prefix, operator: .init("-", padding: .none)),
        .init(for: .mult, associativity: .infix, precedence: .scaling, operator: .init("*")),
        .init(for: .div, associativity: .infix, precedence: .scaling, operator: .init("/")),
        .init(for: .mod, associativity: .infix, precedence: .scaling, operator: .init("%")),
        .init(for: .exp, associativity: .infix, precedence: .exponent, operator: .init("^")),
        .init(for: .sqrt, associativity: .prefix, operator: .init("√", padding: .none)),
        
        // Assignment
        .init(for: .increment, associativity: .postfix, operator: .init("++", padding: .rightSide)),
        .init(for: .decrement, associativity: .postfix, operator: .init("--", padding: .rightSide)),
        .init(for: .mutatingAdd, associativity: .infix, precedence: .assignment, operator: .init("+=")),
        .init(for: .mutatingSub, associativity: .infix, precedence: .assignment, operator: .init("-=")),
        .init(for: .mutatingMult, associativity: .infix, precedence: .assignment, operator: .init("*=")),
        .init(for: .mutatingDiv, associativity: .infix, precedence: .assignment, operator: .init("/=")),
        .init(for: .mutatingConcat, associativity: .infix, precedence: .assignment, operator: .init("&=")),
        .init(for: .assign, associativity: .infix, precedence: .assignment, operator: .init(":=", padding: .bothSides)),
        .init(for: .define, associativity: .prefix, precedence: .assignment),
        .init(for: .del, associativity: .prefix),
        
        // Number
        .init(for: .degrees, associativity: .postfix, operator: .init("°", padding: .none)),
        .init(for: .factorial, associativity: .postfix, operator: .init("!", padding: .none)),
        .init(for: .percent, associativity: .postfix, operator: .init("%", padding: .none)),
        .init(for: .round, associativity: .prefix),
        .init(for: .int, associativity: .prefix),
        .init(for: .npr, associativity: .infix),
        .init(for: .ncr, associativity: .infix),
        
        // Relational
        .init(for: .equates, associativity: .infix, precedence: .equation, operator: .init("=")),
        .init(for: .lessThan, associativity: .infix, precedence: .relational, operator: .init("<")),
        .init(for: .greaterThan, associativity: .infix, precedence: .relational, operator: .init(">")),
        .init(for: .greaterThanOrEquals, associativity: .infix, precedence: .relational, operator: .init(">=")),
        .init(for: .lessThanOrEquals, associativity: .infix, precedence: .relational, operator: .init("<=")),
        .init(for: .equals, associativity: .infix, precedence: .equality, operator: .init("==")),
        .init(for: .notEquals, associativity: .infix, precedence: .equality, operator: .init("!=")),
        
        // Boolean logic
        .init(for: .and, associativity: .infix, precedence: .and, operator: .init("&&")),
        .init(for: .or, associativity: .infix, precedence: .or, operator: .init("||")),
        .init(for: .xor, associativity: .infix, precedence: .xor, operator: .init("^^")),
        .init(for: .not, associativity: .prefix, operator: .init("!", padding: .none)),
        .init(for: .nand, associativity: .infix, precedence: .nand, operator: .init("!&")),
        .init(for: .nor, associativity: .infix, precedence: .nor, operator: .init("!|")),
        
        // List
        .init(for: .get, associativity: .infix, precedence: .subscript, operator: .init("::", padding: .none)), // Preserve arguments?
        .init(for: .size, associativity: .prefix),
        .init(for: .shuffle, associativity: .prefix),
        .init(for: .map, associativity: .infix, operator: .init("|")),
        .init(for: .reduce, associativity: .infix, operator: .init("~")),
        .init(for: .filter, associativity: .infix, operator: .init("|?")),
        .init(for: .zip, associativity: .infix, operator: .init("><")),
        .init(for: .append, associativity: .infix, precedence: .concat, operator: .init("++")),
        .init(for: .sort, associativity: .infix, operator: .init(">?")),
        .init(for: .remove, associativity: .infix),
        .init(for: .contains, associativity: .infix),
        
        // Developer utility
        .init(for: .pipe, associativity: .infix, operator: .init("->")),
        .init(for: .evaluateAt, associativity: .infix, operator: .init("<<")),
        .init(for: .repeat, associativity: .infix, precedence: .repeat, operator: .init("...", padding: .none)),
        .init(for: .copy, associativity: .infix, precedence: .repeat),
        .init(for: .complexity, associativity: .prefix),
        .init(for: .eval, associativity: .prefix),
        .init(for: .print, associativity: .prefix, precedence: .prefixCommand),
        .init(for: .println, associativity: .prefix, precedence: .prefixCommand),
        .init(for: .compile, associativity: .prefix),
        .init(for: .delay, associativity: .prefix),
        .init(for: .run, associativity: .prefix, precedence: .prefixCommand),
        
        // Transfer, flow control, and error handling
        .init(for: .return, associativity: .prefix, precedence: .prefixCommand),
        .init(for: .for, associativity: .prefix),
        .init(for: .ternaryConditional, associativity: .infix, precedence: .conditional, operator: .init("?")),
        .init(for: .assert, associativity: .prefix, precedence: .prefixCommand),
        .init(for: .try, associativity: .prefix, precedence: .prefixCommand),
        .init(for: .throw, associativity: .prefix, precedence: .prefixCommand),
        .init(for: .else, associativity: .infix, precedence: .binding),
        .init(for: .inout, associativity: .prefix, operator: .init("&", padding: .none)),
        
        // Calculus
        .init(for: .derivative, associativity: .infix, precedence: .derivative, operator: .init("'", padding: .none)),
        .init(for: .gradient, associativity: .infix, precedence: .derivative, operator: .init("∇")),
        
        // Type casting
        .init(for: .as, associativity: .infix, precedence: .coersion, operator: .init("!!")),
        .init(for: .is, associativity: .infix, precedence: .coersion, operator: .init("??")),
        
        // Matrix & vector
        .init(for: .determinant, associativity: .prefix),
        .init(for: .dotProduct, associativity: .infix, precedence: .scaling, operator: .init("•")),
        .init(for: .crossProduct, associativity: .infix, precedence: .scaling, operator: .init("×")),
        .init(for: .matrixMultiplication, associativity: .infix, precedence: .scaling, operator: .init("**")),
        .init(for: .transpose, associativity: .prefix, operator: .init("¡", padding: .none)),
        
        // Others
        .init(for: .pair, associativity: .infix, precedence: .pair, operator: .init(":")),
        .init(for: .concat, associativity: .infix, precedence: .concat, operator: .init("&"))
    ]
}
