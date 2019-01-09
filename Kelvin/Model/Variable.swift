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
    static let legalChars = "abcdfghjklmnopqrstuvwxyz_"
    
    /// The name of the variable
    var name: String
    
    var description: String {
        return name
    }
    
    init(_ name: String) throws {
        
        // Check if the variable name is valid
        if !name.contains{Variable.legalChars.contains($0)} {
            let msg = "\"\(name)\" is not a valid variable name."
            throw CompilerError.syntax(errMsg: msg)
        }

        self.name = name
    }
    
    private static func isValid(_ name: String) -> Bool {
        
        return true
    }
    
    func equals(_ node: Node) -> Bool {
        if let v = node as? Variable {
            return v.name == name
        }
        return false
    }
}
