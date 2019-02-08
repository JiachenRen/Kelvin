//
//  Void.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

struct KVoid: LeafNode, NaN {
    var stringified: String {
        return "()"
    }
    
    var ansiColored: String {
        return "()".magenta.bold
    }
    
    func equals(_ node: Node) -> Bool {
        return node is KVoid
    }
    
}
