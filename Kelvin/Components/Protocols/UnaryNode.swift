//
//  UnaryNode.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol UnaryNode: Node {
    var node: Node { get set }
}

extension UnaryNode {
    public var precedence: Keyword.Precedence { .node }
    public var complexity: Int { node.complexity + 1 }
    
    /// Perform an action on each node in the tree.
    public func forEach(_ body: (Node) -> ()) {
        body(self)
        body(node)
    }
    
    /// Returns true if self is the target node or contains the target node;
    /// otherwise return false.
    ///
    /// - Parameters:
    /// - predicament: The condition for the matching node.
    /// - depth: Search depth. Won't search for nodes beyond this designated depth.
    /// - Returns: Whether the current node contains the target node.
    public func contains(where predicament: PUnary, depth: Int) -> Bool {
        if predicament(self) {
            return true
        } else if depth != 0 {
            if node.contains(where: predicament, depth: depth - 1) {
                return true
            }
        }
        
        return false
    }
    
    /// Replaces nodes identical to replacement node.
    ///
    /// - Parameter predicament: The condition that needs to be met for a node to be replaced
    /// - Parameter replace: A function that takes the old node as input (and perhaps ignores it) and returns a node as replacement.
    public func replacing(by replace: (Node) throws -> Node, where predicament: PUnary) rethrows -> Node {
        var copy = self.copy()
        copy.node = try copy.node.replacing(by: replace, where: predicament)
        return predicament(copy) ? try replace(copy) : copy
    }
}
