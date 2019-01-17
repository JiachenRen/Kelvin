//
//  Text.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/12/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension String: Leaf, NaN {
    
    public var stringified: String {
        return self
    }
    
    public func equals(_ node: Node) -> Bool {
        if let s = node as? String {
            return self == s
        }
        return false
    }
}
