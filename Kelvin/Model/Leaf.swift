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
    
    /// Leaf nodes cannot be further simplified by definition.
    public func simplify() -> Node {
        return self
    }
    
    public func toAdditionOnlyForm() -> Node {
        return self
    }
    
    public func toExponentialForm() -> Node {
        return self
    }
    
    public func flatten() -> Node {
        return self
    }
    
}
