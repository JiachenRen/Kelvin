//
//  Final.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/25/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

struct Final: UnaryNode, NaN {
    var node: Node
    
    var stringified: String {
        return node.stringified
    }
    
    var ansiColored: String {
        return node.ansiColored
    }
    
    var complexity: Int {
        return node.complexity + 1
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
    
}
