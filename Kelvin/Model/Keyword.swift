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
    /// the infix keyword "mod" could have an operator of "%"
    var `operator`: Operator?

    /// The associative property of the operator, either prefix, postfix, or infix
    var associativity: Associativity

    /// The precednece of the operator
    var precedence: Precedence

    /// The name of the operation that the keyword is associated with.
    var name: String

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
    var encoding: Encoding

    /// Keyword w/ higher compilation priority are compiled first.
    /// The longer the name of the operator, the higher the compilation priority.
    var compilationPriority: Int {
        return self.operator?.name.count ?? 0
    }

    /// Properly formatted w/ keyword.
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
        _ associativity: Associativity,
        precedence: Precedence = .execution,
        operator: Operator? = nil) {
        self.name = name
        self.associativity = associativity
        self.precedence = precedence
        self.operator = `operator`
        self.encoding = Encoder.next() // Create a unique encoding
    }

    /// Adds a custom defined keyword to encodings and glossary collections.
    public static func define(
        for name: String,
        _ associativity: Associativity,
        precedence: Precedence = .execution,
        operator: Operator? = nil) {

        // Create the keyword
        let keyword = Keyword(for: name, associativity, precedence: precedence, operator: `operator`)

        // Make sure the encoding is currently unassigned and the name is available
        assert(Keyword.encodings[keyword.encoding] == nil)
        assert(Keyword.glossary[name] == nil)

        // Register the keyword in glossary and encodings
        encodings[keyword.encoding] = keyword
        glossary[keyword.name] = keyword
        
        disambiguated = disambiguate()
    }
    
    /**
     Some operations have ambiguous definitions. i.e., they use the same
     operator, but have different associativity.
     e.g. '!', when used as a prefix, means "not" while the same operator used
     as a postfix, say in 'a!', it means factorial.
     This function finds all ambiguous keyword operators.
     */
    public static var disambiguated: [String: [Keyword]] = {
        return disambiguate()
    }()
    
    private static func disambiguate() -> [String: [Keyword]] {
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
        case execution = 1  // ;, ->
        case assignment     // :=, +=, -=, *=, /=
        case equation       // =
        case `repeat`       // ...
        case conditional    // conditional statements like if
        case tuple          // (:)
        case or             // ||
        case and            // &&
        case xor            // ^^
        case equality       // ==, <, >, <=, >=
        case concat         // &
        case addition       // +,-
        case product        // *,/
        case exponent       // ^
        case coersion       // as
        case derivative     // '
        case attached       // ++, --, !, °, prefix and postfix

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
        .init(for: "+", .infix, precedence: .addition, operator: .init("+")),
        .init(for: "-", .infix, precedence: .addition, operator: .init("-")),
        .init(for: "negate", .prefix, precedence: .attached, operator: .init("-", padding: .none)),
        .init(for: "*", .infix, precedence: .product, operator: .init("*")),
        .init(for: "/", .infix, precedence: .product, operator: .init("/")),
        .init(for: "mod", .infix, precedence: .product, operator: .init("%")),
        .init(for: "^", .infix, precedence: .exponent, operator: .init("^")),
        .init(for: "++", .postfix, precedence: .attached, operator: .init("++", padding: .rightSide)),
        .init(for: "--", .postfix, precedence: .attached, operator: .init("--", padding: .rightSide)),
        .init(for: "+=", .infix, precedence: .assignment, operator: .init("+=")),
        .init(for: "-=", .infix, precedence: .assignment, operator: .init("-=")),
        .init(for: "*=", .infix, precedence: .assignment, operator: .init("*=")),
        .init(for: "/=", .infix, precedence: .assignment, operator: .init("/=")),
        .init(for: "sqrt", .prefix, precedence: .attached, operator: .init("√", padding: .none)),
        .init(for: "degrees", .postfix, precedence: .attached, operator: .init("°", padding: .none)),
        .init(for: "factorial", .postfix, precedence: .attached, operator: .init("!", padding: .none)),
        .init(for: "pct", .postfix, precedence: .attached),
        .init(for: "=", .infix, precedence: .equation, operator: .init("=")),
        .init(for: "<", .infix, precedence: .equality, operator: .init("<")),
        .init(for: ">", .infix, precedence: .equality, operator: .init(">")),
        .init(for: ">=", .infix, precedence: .equality, operator: .init(">=")),
        .init(for: "<=", .infix, precedence: .equality, operator: .init("<=")),
        .init(for: "equals", .infix, precedence: .equality, operator: .init("==")),
        .init(for: "and", .infix, precedence: .and, operator: .init("&&")),
        .init(for: "or", .infix, precedence: .or, operator: .init("||")),
        .init(for: "xor", .infix, precedence: .xor, operator: .init("^^")),
        .init(for: "not", .prefix, precedence: .attached, operator: .init("!", padding: .none)),
        .init(for: "define", .infix, precedence: .assignment, operator: .init(":=", padding: .bothSides)),
        .init(for: "def", .prefix, precedence: .assignment),
        .init(for: "del", .prefix),
        .init(for: "get", .infix, precedence: .attached, operator: .init("::", padding: .none)), // Preserve arguments?
        .init(for: "size", .prefix, precedence: .attached),
        .init(for: "map", .infix, operator: .init("|")),
        .init(for: "reduce", .infix, operator: .init("~")),
        .init(for: "filter", .infix, operator: .init("|?")),
        .init(for: "zip", .infix, operator: .init("><")),
        .init(for: "append", .infix, operator: .init("++")),
        .init(for: "sort", .infix, operator: .init(">?")),
        .init(for: "then", .infix, operator: .init(";", padding: .rightSide)),
        .init(for: "feed", .infix, operator: .init("->")),
        .init(for: "replace", .infix, operator: .init("<<")),
        .init(for: "repeat", .infix, precedence: .repeat, operator: .init("...", padding: .none)),
        .init(for: "copy", .infix, precedence: .repeat),
        .init(for: "complexity", .prefix),
        .init(for: "round", .prefix, precedence: .attached),
        .init(for: "int", .prefix, precedence: .attached),
        .init(for: "eval", .prefix),
        .init(for: "print", .prefix),
        .init(for: "println", .prefix),
        .init(for: "compile", .prefix),
        .init(for: "run", .prefix),
        .init(for: "try", .prefix),
        .init(for: "npr", .infix),
        .init(for: "ncr", .infix),
        .init(for: "tuple", .infix, precedence: .tuple, operator: .init(":")),
        .init(for: "if", .infix, precedence: .conditional, operator: .init("?")),
        .init(for: "concat", .infix, precedence: .concat, operator: .init("&")),
        .init(for: "derivative", .infix, precedence: .derivative, operator: .init("'", padding: .none)),
        .init(for: "as", .infix, precedence: .coersion, operator: .init("!!")),
        .init(for: "grad", .infix, precedence: .derivative, operator: .init("∇")),
        .init(for: "det", .prefix, precedence: .attached),
        .init(for: "dotP", .infix, precedence: .product, operator: .init("•")),
        .init(for: "crossP", .infix, precedence: .product, operator: .init("×"))
    ]
}
