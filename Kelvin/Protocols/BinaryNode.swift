//
//  BinaryNode.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

protocol BinaryNode: MutableListProtocol {
    var rhs: Node { get set }
    var lhs: Node { get set }
}

extension BinaryNode {
    public var elements: [Node] {
        get {
            return [lhs, rhs]
        }
        set {
            lhs = newValue[0]
            rhs = newValue[1]
        }
    }
}

