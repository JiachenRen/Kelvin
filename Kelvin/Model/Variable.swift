//
//  Var.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

struct Variable: Leaf, NaN {
    
    /// The characters that are allowed in the variable
    static let legalChars = "abcdefghijklmnopqrstuvwxyz_"
    
    static var definitions: [String: Node] = [
        "e": M_E,
        "pi": Double.pi
    ]
    
    /// The name of the variable
    var name: String
    
    var description: String {
        return name
    }
    
    /// Extract the definition of the variable from the definitions.
    var definition: Node? {
        return Variable.definitions[name]
    }
    
    /// Whether the variable represents a constant.
    /// e.g. pi, e
    var isConstant: Bool {
        if let def = definition {
            return def is Double
        }
        return false
    }
    
    var evaluated: Value? {
        return definition?.evaluated
    }
    
    init(_ name: String) throws {
        
        // Check if the variable name is valid
        for ch in name {
            if !Variable.legalChars.contains(ch) {
                let msg = "\"\(name)\" is not a valid variable name."
                throw CompilerError.syntax(errMsg: msg)
            }
        }

        self.name = name
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
    func equals(_ node: Node) -> Bool {
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
    func simplify() -> Node {
        if let def = definition {
            // If the definition is not a constant, return the definition
            return isConstant && Mode.shared == .exact ? self : def
        }
        return self
    }
}
