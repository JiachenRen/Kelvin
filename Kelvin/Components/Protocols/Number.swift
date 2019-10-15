//
//  Number.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation


public protocol Number: LeafNode {
    var float80: Float80 { get }
}

extension Number {
    public var evaluated: Number? { self }
    public var stringified: String { "\(self)" }

    public func equals(_ node: Node) -> Bool {
        if let d = node as? Number {
            return d.float80 == float80
        }
        return false
    }
}
