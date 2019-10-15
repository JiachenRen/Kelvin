//
//  String.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/12/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension String: LeafNode, NaN {
    public var stringified: String { "\"\(self)\"" }
    public var ansiColored: String { "\"\(self)\"".green }
    
    public func equals(_ node: Node) -> Bool {
        if let str = node as? String {
            return str == self
        }
        return false
    }
}
