//
//  Void.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct KVoid: LeafNode, NaN {
    public var stringified: String {
        return "()"
    }
    
    public var ansiColored: String {
        return "()".magenta.bold
    }
    
    public func equals(_ node: Node) -> Bool {
        return node is KVoid
    }
}
