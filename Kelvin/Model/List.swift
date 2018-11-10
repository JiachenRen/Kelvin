//
//  List.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

struct List: Node {
    var numericVal: Double? {
        return nil
    }
    
    let nodes: [Node]
    
    func simplify() -> Node {
        return List(nodes.map{$0.simplify()})
    }
    
    var description: String {
        var pars = nodes.map{$0.description}
            .reduce(""){"\($0),\($1)"}
        pars.removeFirst()
        return pars
    }
    
    init(_ nodes: [Node]) {
        self.nodes = nodes
    }
    
    init(_ nodes: Node...) {
        self.init(nodes)
    }
}
