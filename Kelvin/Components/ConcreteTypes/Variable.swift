//
//  Var.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public class Variable: LeafNode, NaN {
    public static var definitions: [String: Node] = [:]
    public static let validationRegex = Regex(pattern: "^[a-zA-Z_$]+[a-zA-Z_\\d]*$")
    public var name: String

    /// Extract the definition of the variable from the definitions.
    public var definition: Node? { Variable.definitions[name] }
    
    /// Anonymous arguments are replaced by their callers with supplied expressions.
    public var isAnonymous: Bool {
        return name.starts(with: "$") && Int(name[1..<name.count]) != nil
    }

    public required init?(_ name: String) {
        if !(name ~ Variable.validationRegex) {
            return nil
        }
        self.name = name
    }
    
    internal init() {
        self.name = "\(Tokenizer.next())"
    }

    /// Clear all variable definitions and reload all constants.
    public static func restoreDefault() {
        definitions = [:]
    }

    /// Assign a definition to variables with the given name. Duplicate definitions are overriden.
    /// - Parameters:
    ///    - name: The name of the variable
    ///    - def: The definition of the variable, can be a number, expression, or equation.
    public static func define(_ name: String, _ def: Node) {
        definitions.updateValue(def, forKey: name)
    }

    /// Remove the definition of the variables with the given name.
    /// - Parameter name: The name of the variable to be deleted.
    public static func delete(_ name: String) {
        definitions.removeValue(forKey: name)
    }
    
    // MARK: - Node

    /// If the variable does not have a definition, the variable itself is returned.
    /// If the variable is a constant, then depending on the mode, the exact value
    /// of the constant or the name of the constant is returned.
    /// - `.exact`: the name of the constant is returned;
    /// - `.approximate`: the value of the constant is returned.
    ///
    /// - Returns: The simplified variable.
    public func simplify() throws -> Node {
        if let def = definition {
            do {
                return try def.simplify()
            } catch let e as KelvinError {
                throw ExecutionError.onNode(self, err: e)
            }
        }
        return self
    }
    
    /// Two variables are equal to each other if they have the same name.
    public func equals(_ node: Node) -> Bool {
        if let v = node as? Variable {
            return v.name == name
        }
        return false
    }
    
    public var sanitized: String {
        name.replacingOccurrences(
            of: #"[^a-zA-Z$_\d]"#,
            with: "",
            options: .regularExpression
        )
    }
    public var stringified: String { sanitized }
    public var ansiColored: String { isAnonymous ? sanitized.cyan.bold : sanitized }
    public var complexity: Int { 3 }
    public var evaluated: Number? { definition?.evaluated }
}
