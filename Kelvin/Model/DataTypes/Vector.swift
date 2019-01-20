//
//  Vector.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

struct Vector: MutableListProtocol, NaN {
    
    var elements: [Node]
    
    var stringified: String {
        let e = elements.reduce(nil) {
            $0 == nil ? $1 : "\($0!), \($1)"
        } ?? ""
        return "[\(e)]"
    }
    
    init(_ components: [Node]) {
        self.elements = components
    }
    
    func equals(_ node: Node) -> Bool {
        if let v = node as? Vector {
            return equals(list: v)
        }
        return false
    }
    
}
