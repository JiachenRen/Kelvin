//
//  BinaryNode.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol BinaryNode: Node {
    var elements: [Node] { get set }
}

extension BinaryNode {
    var lhs: Node {
        get { elements[0] }
        set { elements[0] = newValue }
    }
    
    var rhs: Node {
        get { elements[1] }
        set { elements[1] = newValue }
    }
}

