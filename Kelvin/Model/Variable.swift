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
        if !Variable.isValid(name) {
            throw CompilerError.syntax(errMsg: "\"\(name)\" is not a valid variable name.")
        }
        self.name = name
    }
    
    private static func isValid(_ name: String) -> Bool {
        for char in name {
            if !legalChars.contains(char) {
                return false
            }
        }
        return true
    }
}
