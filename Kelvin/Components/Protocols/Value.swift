//
//  Value.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation


public protocol Value: LeafNode {
    var float80: Float80 { get }
}

extension Value {
    public var evaluated: Value? { self }
    public var stringified: String { "\(self)" }
    public static var kType: KType { .number }

    public func equals(_ node: Node) -> Bool {
        if let d = node as? Value {
            return d.float80 == float80
        }
        return false
    }
}
