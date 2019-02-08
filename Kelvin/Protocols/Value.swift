//
//  Number.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation


public protocol Value: LeafNode {
    var doubleValue: Double { get }
}

extension Value {
    public var evaluated: Value? {
        return self
    }

    public var stringified: String {
        return "\(self)"
    }

    public func equals(_ node: Node) -> Bool {
        if let d = node as? Value {
            return d.doubleValue == doubleValue
        }
        return false
    }
}
