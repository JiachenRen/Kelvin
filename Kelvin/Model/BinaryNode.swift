//
//  BinaryNode.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

protocol BinaryNode: Node {
    var rhs: Node {get}
    var lhs: Node {get}
}

extension BinaryNode {
    
    /// Perform an action on each node in the tree.
    public func forEach(_ body: (Node) -> ()) {
        body(self)
        lhs.forEach(body)
        rhs.forEach(body)
    }
    
    /**
     If either side contains the node, then return true
     Else if self is node, return true, other wise return false.
     
     - Parameters:
     - predicament: The condition for the matching node.
     - depth: Search depth. Won't search for nodes beyond this designated depth.
     - Returns: Whether the current node contains the target node.
     */
    public func contains(where predicament: (Node) -> Bool, depth: Int) -> Bool {
        if predicament(self) {
            return true
        } else if depth != 0 {
            for n in [lhs, rhs] {
                if n.contains(where: predicament, depth: depth - 1) {
                    return true
                }
            }
        }
        return false
    }
}
