//
//  Pair.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/18/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Pair: BinaryNode, NaN {
    
    public var stringified: String {
        return "\(lhs.stringified) : \(rhs.stringified)"
    }
    
    public var ansiColored: String {
        return "\(lhs.ansiColored) : \(rhs.ansiColored)"
    }
    
    public var precedence: Keyword.Precedence {
        return .pair
    }
    
    /// First value of the pair
    var lhs: Node
    
    /// Second value of the pair
    var rhs: Node
    
    init(_ v1: Node, _ v2: Node) {
        self.lhs = v1
        self.rhs = v2
    }
    
    init(_ ks: String, _ v2: Node) {
        self.lhs = KString(ks)
        self.rhs = v2
    }
    
    public func equals(_ node: Node) -> Bool {
        if let t = node as? Pair {
            return equals(list: t)
        }
        return false
    }
}
