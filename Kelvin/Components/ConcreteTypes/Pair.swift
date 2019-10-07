//
//  Pair.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/18/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Pair: Iterable, BinaryNode {
    public var stringified: String { concat(by: " : ") { $0.stringified } }
    public var ansiColored: String { concat(by: " : ") { $0.ansiColored } }
    public var precedence: Keyword.Precedence { .pair }
    public class var kType: KType { .pair }
    public var elements: [Node]
    
    public required init(_ v1: Node, _ v2: Node) {
        self.elements = [v1, v2]
    }
    
    public convenience init(_ key: String, _ val: Node) {
        self.init(KString(key), val)
    }
    
    public func equals(_ other: Node) -> Bool {
        guard let pair = other as? Pair else {
            return false
        }
        return equals(list: pair)
    }
    
    public func copy() -> Self {
        return Self(lhs, rhs)
    }
}
