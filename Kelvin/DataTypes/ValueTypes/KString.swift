//
//  Text.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/12/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

struct KString: LeafNode, NaN {
    
    var stringified: String {
        return "\"\(string)\""
    }
    
    var ansiColored: String {
        return "\"\(string)\"".green
    }
    
    let string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    func equals(_ node: Node) -> Bool {
        if let kString = node as? KString {
            return kString.string == string
        }
        return false
    }
    
    func concat(_ ks: KString) -> KString {
        return KString("\(string)\(ks.string)")
    }
}
