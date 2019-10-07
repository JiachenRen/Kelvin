//
//  Final.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/25/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

final class Final: UnaryNode, NaN {
    class var kType: KType { .unknown }
    var stringified: String { node.stringified }
    var ansiColored: String { node.ansiColored }
    var node: Node
    
    init(_ node: Node) {
        self.node = node
    }
    
    func simplify() throws -> Node {
        return node
    }
    
    func equals(_ node: Node) -> Bool {
        guard let f = node as? Final else {
            return false
        }
        return f.node === self.node
    }
    
    func copy() -> Self {
        return Self(node.copy())
    }
}
