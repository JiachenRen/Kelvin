//
//  Bool+Value.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Bool: LeafNode, NaN {
    public var stringified: String {
        return "\(self)"
    }
    
    public func equals(_ node: Node) -> Bool {
        if let b = node as? Bool {
            return b == self
        }
        return false
    }
    
    public var ansiColored: String {
        return self ? "\(self)".green.bold : "\(self)".red.bold
    }
}
