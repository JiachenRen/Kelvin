//
//  Leaf.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/7/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol Leaf: Node {
}

extension Leaf {
    
    /// Leaf nodes have a complexity of 1
    public var complexity: Int {
        return 1
    }
    
    /// Leaf nodes cannot be further simplified by definition.
    public func simplify() -> Node {
        return self
    }
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
     ignores it) and returns a node as replacement.
     */
    public func replacing(by replace: Unary, where predicament: (Node) -> Bool) -> Node {
        return predicament(self) ? replace(self) : self
    }
    
}
