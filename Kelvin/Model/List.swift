//
//  List.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

struct List: Node, NaN {
    
    var elements: [Node]
    
    var description: String {
        var pars = elements.map{$0.description}
            .reduce(""){"\($0),\($1)"}
        if pars.count > 0 {
            pars.removeFirst()
        }
        return "{\(pars)}"
    }
    
    init(_ elements: [Node]) {
        self.elements = elements
    }
    
    init(_ elements: Node...) {
        self.init(elements)
    }
    
    /**
     Simplify each element in the list.
     
     - Returns: A copy of the list with each element simplified.
     */
    func simplify() -> Node {
        return List(elements.map{$0.simplify()})
    }
    
    /// Convert all subtractions to additions
    func toAdditionOnlyForm() -> Node {
        return List(elements.map{$0.toAdditionOnlyForm()})
    }
    
    /// Convert all divisions to multiplications and exponentiations
    func toExponentialForm() -> Node {
        return List(elements.map{$0.toExponentialForm()})
    }
    
    /// Flatten binary operation trees
    func flatten() -> Node {
        return List(elements.map{$0.flatten()})
    }
    
    /// - Returns: Whether the provided node is identical with self.
    func equals(_ node: Node) -> Bool {
        if let list = node as? List, list.elements.count == elements.count {
            for i in 0..<elements.count {
                if !elements[i].equals(list.elements[i]) {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
                            ignores it) and returns a node as replacement.
     */
    func replacing(by replace: Unary, where predicament: (Node) -> Bool) -> Node {
        var copy = self
        copy.elements = copy.elements.map{ element in
            return element.replacing(by: replace, where: predicament)
        }
        return predicament(copy) ? replace(copy) : copy
    }
}
