//
//  ListProtocol.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

protocol ListProtocol: Node {
    var elements: [Node] {get}
}

extension ListProtocol {
    
    var count: Int {
        return elements.count
    }
    
    subscript(_ idx: Int) -> Node {
        get {
            return elements[idx]
        }
    }
    
    /// Complexity of the list is the complexity of all its elements + 1.
    public var complexity: Int {
        return elements.reduce(0) {
            $0 + $1.complexity
            } + 1
    }
    
    /// Perform an action on each node in the tree.
    public func forEach(_ body: (Node) -> ()) {
        body(self)
        for e in elements {
            e.forEach(body)
        }
    }
    
    /**
     If self is the target node or any of the elements contains the target,
     then return true; otherwise return false.
     - Parameters:
     - predicament: The condition for the matching node.
     - depth: Search depth. Won't search for nodes beyond this designated depth.
     - Returns: Whether the current node contains the target node.
     */
    public func contains(where predicament: PUnary, depth: Int) -> Bool {
        if predicament(self) {
            return true
        } else if depth != 0 {
            for e in elements {
                if e.contains(where: predicament, depth: depth - 1) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /**
     Split the list of elements into two groups, with the first group satisfying
     the predicament and the second group being the rest.
     
     - Parameter predicament: The condition for splitting into the first list
     - Returns: A tuple with the first element being the sublist of elements satisfying the predicament.
     */
    public func split(by predicament: PUnary) -> ([Node], [Node]) {
        var o = self.elements
        
        var s = [Node]()
        for (i, e) in o.enumerated() {
            if predicament(e) {
                s.append(o.remove(at: i))
            }
        }
        
        return (s, o)
    }
    
    /**
     Check if the two lists are strictly equivalent, i.e. order does matter.
     
     - Parameter node: Another list to be compared to.
     - Returns: Whether self and node are equal.
     */
    public func equals(list: ListProtocol) -> Bool {
        if list.count != count {
            return false
        }

        for i in 0..<list.elements.count {
            if self[i] !== list[i] {
                return false
            }
        }
        return true
    }
    
    public func map(by unary: (Node) throws -> Node) rethrows -> [Node] {
        return try elements.map(unary)
    }
}
