//
//  Var.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

struct Var: LeafNode {
    var numericVal: Double? {
        return nil
    }
    
    static let legalChars = "abcdfghjklmnopqrstuvwxyz_"
    var name: String
    
    var description: String {
        return name
    }
    
    init?(_ name: String) {
        if Var.isValid(name) {
            self.name = name
        } else {
            return nil
        }
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
