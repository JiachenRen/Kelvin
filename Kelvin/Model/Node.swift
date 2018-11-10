//
//  Node.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol Node: CustomStringConvertible {
    var numericVal: Double? {get}
    func simplify() -> Node
}

public protocol LeafNode: Node {
}

extension LeafNode {
    public func simplify() -> Node {
        return self
    }
}

