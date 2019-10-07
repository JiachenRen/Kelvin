//
//  Bool+Node.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Bool: LeafNode, NaN {
    public static var kType: KType { .bool }
    public var stringified: String { "\(self)" }
    public var ansiColored: String { self ? "\(self)".green.bold : "\(self)".red.bold }
    
    public func equals(_ node: Node) -> Bool {
        if let b = node as? Bool {
            return b == self
        }
        return false
    }
}
