//
//  List.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public struct List: Node, NaN {
    
    var elements: [Node]
    
    public var description: String {
        let pars = elements.map {$0.description}.reduce(nil) {
            $0 == nil ? "\($1)": "\($0!), \($1)"
        }
        return "{\(pars ?? "")}"
    }
    
    init(_ elements: [Node]) {
        self.elements = elements
    }
    
    init(_ elements: Node...) {
        self.init(elements)
    }
    
    subscript(_ idx: Int) -> Node {
        get {
            return elements[idx]
        }
        set(newValue) {
            elements[idx] = newValue
        }
    }
    
    /**
     Simplify each element in the list.
     
     - Returns: A copy of the list with each element simplified.
     */
    public func simplify() -> Node {
        return List(elements.map{$0.simplify()})
    }
    
    /// Convert all subtractions to additions
    public func toAdditionOnlyForm() -> Node {
        return List(elements.map{$0.toAdditionOnlyForm()})
    }
    
    /// Convert all divisions to multiplications and exponentiations
    public func toExponentialForm() -> Node {
        return List(elements.map{$0.toExponentialForm()})
    }
    
    /// Flatten binary operation trees
    public func flatten() -> Node {
        return List(elements.map{$0.flatten()})
    }
    
    /// The ordering of the list does not matter, i.e. {1,2,3} is considered
    /// the same as {3,2,1}.
    /// - Returns: Whether the provided node is loosely identical to self.
    public func equals(_ node: Node) -> Bool {
        
        func comparator(_ lhs: Node, _ rhs: Node) -> Bool {
            return "\(lhs)" > "\(rhs)"
        }
        
        if let list = node as? List, list.elements.count == elements.count {
            let l1 = sorted(by: comparator)
            let l2 = list.sorted(by: comparator)
            return List.strictlyEquals(l1, l2)
        }
        return false
    }
    
    /**
     Sort the list by using the provided comparator.
     
     - Parameter comparator: A binary function that compares two nodes.
     - Returns: A new list containing the original elements in sorted order
     */
    public func sorted(by comparator: (Node, Node) -> Bool) -> List {
        return List(elements.sorted(by: comparator))
    }
    
    /**
     Check if the two lists are strictly equivalent, i.e. order does matter.
     
     - Parameter lhs: A list
     - Parameter rhs: Another list to be compared to.
     - Returns: Whether lhs and rhs are strictly equivalent.
     */
    public static func strictlyEquals(_ lhs: List, _ rhs: List) -> Bool {
        if lhs.elements.count != rhs.elements.count {
            return false
        }
        for i in 0..<lhs.elements.count {
            if lhs[i] !== rhs[i] {
                return false
            }
        }
        return true
    }
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
                            ignores it) and returns a node as replacement.
     */
    public func replacing(by replace: Unary, where predicament: (Node) -> Bool) -> Node {
        var copy = self
        copy.elements = copy.elements.map{ element in
            return element.replacing(by: replace, where: predicament)
        }
        return predicament(copy) ? replace(copy) : copy
    }
}
