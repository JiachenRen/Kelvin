//
//  Keyword.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Keyword {
    /// The custom operator for a keyword. For example, infix operator `%` can be assigned to`.mod`
    public var `operator`: Operator?

    /// The associative property of the operator, either prefix, postfix, or infix
    public var associativity: Associativity

    /// The precednece of the operator
    public var precedence: Precedence

    /// The name of the operation that the keyword is associated with.
    public var name: String
    
    /// A single character is used to encode the operation;
    /// By doing so, the compiler can treat the operation like `+,-,*,/`, and so on.
    var token: Token
    
    /// Keyword w/ higher compilation priority are compiled first.
    /// The longer the name of the operator, the higher the compilation priority.
    var compilationPriority: Int {
        return self.operator?.name.count ?? 0
    }

    var formatted: String {
        if let o = self.operator {
            switch Mode.shared.outputFormat {
            case .default where o.isPreferred,
                 .prefersSymbols:
                return o.description
            default:
                break
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
    
    /// Instantiates a new `Keyword`. Keyword contains compilation properties for the name of a function.
    /// - Parameters:
    ///     - name: Name of the keyword (i.e. name of the function)
    ///     - associativity: Associativity of the keyword
    init(for name: String, associativity: Associativity, precedence: Precedence? = nil, operator: Operator? = nil) {
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
        self.token = Tokenizer.next() // Create a unique token
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
        case translating        // +, -
        case scaling            // *, /
        case exponent           // ^
        case binary             // derivative('), as(!!), gradient(∇), ncr, npr.
        case prefixA            // ambiguous prefix
        case prefix             // √, !(not), * prefix as function reference
        case postfix            // ++, --, !(factorial), °, %
        case invocation         // <<<
        case `subscript`        // ::
        case binding            // binding between closures
        case node               // leaf nodes should never require parenthesis

        public static func <(lhs: Precedence, rhs: Precedence) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}
