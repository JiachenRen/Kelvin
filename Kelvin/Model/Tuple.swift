//
//  Tuple.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/18/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

struct Tuple: BinaryNode, NaN {
    var complexity: Int {
        return lhs.complexity + rhs.complexity + 1
    }
    
    var stringified: String {
        return "(\(lhs) : \(rhs))"
    }
    
    /// First value of the tuple
    let lhs: Node
    
    /// Second value of the tuple
    let rhs: Node
    
    init(_ v1: Node, _ v2: Node) {
        self.lhs = v1
        self.rhs = v2
    }
    
    func simplify() -> Node {
        return Tuple(lhs.simplify(), rhs.simplify())
    }
    
    func equals(_ node: Node) -> Bool {
        if let t = node as? Tuple {
            return lhs === t.lhs && rhs === t.rhs
        }
        return false
    }
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
     ignores it) and returns a node as replacement.
     */
    func replacing(by replace: (Node) -> Node, where predicament: (Node) -> Bool) -> Node {
        let t = Tuple(lhs.replacing(by: replace, where: predicament), rhs.replacing(by: replace, where: predicament))
        return predicament(t) ? replace(t) : t
    }
}
