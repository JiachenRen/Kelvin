//
//  KBool.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

extension Bool: LeafNode {
    public var numericVal: Double? {
        return nil
    }
    
    public func simplify() -> Node {
        return self
    }
    
    var description: String {
        return "\(self)"
    }
    
    func negate() -> Bool {
        return !self
    }
    
}
