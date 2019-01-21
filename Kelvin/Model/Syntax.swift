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
 For the function with signature ".init(f(x)=x^2)",
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
    public static var lexicon: [Encoding: Syntax] = {
        defaultDefinitions.reduce(into: [:]) {
            $0[$1.encoding] = $1
        }
    }()

    /// A dictionary that maps a common name to a syntax component.
    public static var glossary: [String: Syntax] = {
        defaultDefinitions.reduce(into: [:]) {
            $0[$1.commonName] = $1
        }
    }()

    /// A single character is used to encode the operation;
    /// By doing so, the compiler can treat the operation like +,-,*,/, and so on.
    var encoding: Encoding

    /// Syntax w/ higher compilation priority are compiled first.
    /// The longer the name of the operator, the higher the compilation priority.
    var compilationPriority: Int {
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

    fileprivate init(for commonName: String, _ position: Position, priority: Priority = .execution, operator: Operator? = nil) {
        self.commonName = commonName
        self.position = position
        self.priority = priority
        self.operator = `operator`
        self.encoding = Encoder.next() // Create a unique encoding
    }

    /// Adds a custom defined syntax to lexicon and glossary collections.
    public static func define(for commonName: String, _ position: Position, priority: Priority = .execution, operator: Operator? = nil) {

        // Create the syntax
        let syntax = Syntax(for: commonName, position, priority: priority, operator: `operator`)

        // Make sure the encoding is currently unassigned and the name is available
        assert(Syntax.lexicon[syntax.encoding] == nil)
        assert(Syntax.glossary[commonName] == nil)

        // Register the syntax in glossary and lexicon
        lexicon[syntax.encoding] = syntax
        glossary[syntax.commonName] = syntax
    }

    /// Reset to syntactic definitions for operations by
    /// First reset encoder scalar, then reload glossary and lexicon
    public static func restoreDefault() {
        lexicon = defaultDefinitions.reduce(into: [:]) {
            $0[$1.encoding] = $1
        }
        glossary = defaultDefinitions.reduce(into: [:]) {
            $0[$1.commonName] = $1
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

    public enum Position {
        case prefix
        case infix
        case postfix
    }

    public enum Priority: Int, Comparable {
        case execution = 1  // ;, ->
        case definition     // :=
        case equation       // =
        case `repeat`       // ...
        case conditional    // conditional statements like if
        case tuple          // (:)
        case or             // ||
        case and            // &&
        case equality       // ==, <, >, <=, >=
        case concat         // &
        case addition       // +,-
        case product        // *,/
        case exponent       // ^

        public static func <(lhs: Priority, rhs: Priority) -> Bool {
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

    /// Default syntax definitions
    private static let defaultDefinitions: [Syntax] = [
        .init(for: "+", .infix, priority: .addition, operator: .init("+")),
        .init(for: "-", .infix, priority: .addition, operator: .init("-")),
        .init(for: "*", .infix, priority: .product, operator: .init("*")),
        .init(for: "/", .infix, priority: .product, operator: .init("/")),
        .init(for: "mod", .infix, priority: .product, operator: .init("%")),
        .init(for: "^", .infix, priority: .exponent, operator: .init("^")),
        .init(for: "sqrt", .prefix, priority: .exponent, operator: .init("√", padding: .none)),
        .init(for: "degrees", .postfix, priority: .exponent, operator: .init("°", padding: .none)),
        .init(for: "factorial", .postfix, priority: .exponent, operator: .init("!", padding: .none)),
        .init(for: "pct", .postfix, priority: .exponent),
        .init(for: "=", .infix, priority: .equation, operator: .init("=")),
        .init(for: "<", .infix, priority: .equality, operator: .init("<")),
        .init(for: ">", .infix, priority: .equality, operator: .init(">")),
        .init(for: ">=", .infix, priority: .equality, operator: .init(">=")),
        .init(for: "<=", .infix, priority: .equality, operator: .init("<=")),
        .init(for: "equals", .infix, priority: .equality, operator: .init("==")),
        .init(for: "and", .infix, priority: .and, operator: .init("&&")),
        .init(for: "or", .infix, priority: .or, operator: .init("||")),
        .init(for: "define", .infix, priority: .definition, operator: .init(":=", padding: .bothSides)),
        .init(for: "def", .prefix, priority: .definition),
        .init(for: "del", .prefix),
        .init(for: "get", .infix, priority: .exponent, operator: .init("::", padding: .none)), // Preserve arguments?
        .init(for: "size", .prefix, priority: .exponent),
        .init(for: "map", .infix, operator: .init("|")),
        .init(for: "reduce", .infix, operator: .init("~")),
        .init(for: "then", .infix, operator: .init(";", padding: .rightSide)),
        .init(for: "feed", .infix, operator: .init("->")),
        .init(for: "repeat", .infix, priority: .repeat, operator: .init("...", padding: .none)),
        .init(for: "copy", .infix, priority: .repeat),
        .init(for: "complexity", .prefix),
        .init(for: "round", .prefix, priority: .exponent),
        .init(for: "int", .prefix, priority: .exponent),
        .init(for: "eval", .prefix),
        .init(for: "print", .prefix),
        .init(for: "println", .prefix),
        .init(for: "compile", .prefix),
        .init(for: "npr", .infix),
        .init(for: "ncr", .infix),
        .init(for: "tuple", .infix, priority: .tuple, operator: .init(":", padding: .bothSides)),
        .init(for: "if", .infix, priority: .conditional, operator: .init("?", padding: .bothSides)),
        .init(for: "concat", .infix, priority: .concat, operator: .init("&", padding: .bothSides)),
        .init(for: "derivative", .infix, priority: .exponent, operator: .init("'", padding: .bothSides)),
    ]
}
