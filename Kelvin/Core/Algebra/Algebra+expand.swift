//
//  Algebra.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension Algebra {
    
    /**
     Try this:
     expand((x+1)(a+x)(b+x))
     
     - Todo: Handle exponents "x^(a+b) -> x^a*x^b"
     */
    static func expand(_ node: Node) -> Node {
        return node.replacing(by: {(n) -> Node in
                recursivelyExpand(n)
            }) {
                if let fun = $0 as? Function {
                    if fun.name == .mult && fun.contains(where: {($0 as? Function)?.name == .add}, depth: 1) {
                        return true
                    }
                }
                return false
        }
    }
    
    /**
     Recursively expand the expression.
     */
    private static func recursivelyExpand(_ node: Node) -> Node {
        guard var nodes = (node as? Function)?.elements else {
            return node
        }
        
        for i in 0..<nodes.count {
            let n = nodes.remove(at: i)
            if let f = n as? Function, f.name == .add {
                return ++(f.elements.map {
                    recursivelyExpand($0 * **nodes)
                })
            }
            nodes.insert(n, at: i)
        }
        
        return node
    }
    
}
