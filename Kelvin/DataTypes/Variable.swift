//
//  Var.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Variable: LeafNode, NaN {

    static var definitions: [String: Node] = {
        constants.reduce(into: [:]) {
            $0[$1.key] = $1.value
        }
    }()

    static var constants: [String: Double] = [
        "e": M_E,
        "pi": Double.pi,
        "inf": Double.infinity,
    ]

    /// The name of the variable
    var name: String

    public static let validationRegex = Regex(pattern: "^[a-zA-Z_$]+[a-zA-Z_\\d]*$")
    
    public var stringified: String {
        return name
    }
    
    public var ansiColored: String {
        if definition != nil {
            return isConstant ? name.bold.magenta : name.bold
        }
        return isAnonymous ? name.cyan.bold : name;
    }

    /// Extract the definition of the variable from the definitions.
    var definition: Node? {
        return Variable.definitions[name]
    }

    /// Whether the variable represents a constant.
    /// e.g. pi, e
    var isConstant: Bool {
        return Variable.constants[name] != nil
    }
    
    /// Anonymous arguments are replaced by their callers
    /// with supplied expressions.
    var isAnonymous: Bool {
        return name.starts(with: "$")
    }

    public var evaluated: Value? {
        return definition?.evaluated
    }

    /// Variables have a complexity of 2.
    public var complexity: Int {
        return 3
    }

    init(_ name: String) throws {

        // Check if the variable name is valid
        if !(name ~ Variable.validationRegex) {
            throw CompilerError.syntax(errMsg: "illegal variable name '\(name)'")
        }

        self.name = name
    }

    /// Clear all variable definitions and reload all constants.
    public static func restoreDefault() {
        definitions = constants.reduce(into: [:]) {
            $0[$1.key] = $1.value
        }
    }

    /**
     Assign a definition to variables with the given name.
     
     - Warning: Conflicts are overriden.
     - Parameters:
        - name: The name of the variable
        - def: The definition of the variable, can be a number, expression, or equation.
     */
    static func define(_ name: String, _ def: Node) {
        definitions.updateValue(def, forKey: name)
    }

    /**
     Remove the definition of the variables with the given name.
     
     - Parameter name: The name of the variable to be deleted.
     */
    static func delete(_ name: String) {
        definitions.removeValue(forKey: name)
    }

    /// Two variables are equal to each other if they have the same name.
    public func equals(_ node: Node) -> Bool {
        if let v = node as? Variable {
            return v.name == name
        }
        return false
    }

    /**
     If the variable does not have a definition, the variable itself is returned.
     If the variable is a constant, then depending on the mode, the exact value
     of the constant or the name of the constant is returned.
     - Mode.exact: the name of the constant is returned;
     - Mode.approximate: the value of the constant is returned.
     
     - Returns: The simplified variable.
     */
    public func simplify() -> Node {
        if let def = definition {
            // If the definition is not a constant, return the definition
            return isConstant && Mode.shared.rounding == .exact ? self : def
        }
        return self
    }
}
