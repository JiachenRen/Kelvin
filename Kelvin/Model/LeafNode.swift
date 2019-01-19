//
//  Leaf.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/7/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol LeafNode: Node {
}

extension LeafNode {

    /// Leaf nodes have a complexity of 1
    public var complexity: Int {
        return 1
    }

    /// Leaf nodes cannot be further simplified by definition.
    public func simplify() -> Node {
        return self
    }

    /// Perform an action on each node in the tree.
    public func forEach(_ body: (Node) -> ()) {
        body(self)
    }

    /**
     If self satisfies target node, then return true, otherwise return false.
     
     - Parameters:
        - predicament: The condition for the matching node.
        - depth: Search depth. Won't search for nodes beyond this designated depth.
     - Returns: Whether the current node contains the target node.
     */
    public func contains(where predicament: PUnary, depth: Int) -> Bool {
        return predicament(self)
    }

    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
     ignores it) and returns a node as replacement.
     */
    public func replacing(by replace: Unary, where predicament: PUnary) -> Node {
        return predicament(self) ? replace(self) : self
    }

}
