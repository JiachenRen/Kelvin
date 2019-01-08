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
        pars.removeFirst()
        return pars
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
    
    func toAdditionOnlyForm() -> Node {
        return List(elements.map{$0.toAdditionOnlyForm()})
    }
    
    func toExponentialForm() -> Node {
        return List(elements.map{$0.toExponentialForm()})
    }
    
    func flatten() -> Node {
        return List(elements.map{$0.flatten()})
    }
}
