//
//  KVoid.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct KVoid: LeafNode, NaN {
    public func equals(_ node: Node) -> Bool { node is KVoid }
    public var stringified: String { "()" }
    public var ansiColored: String { "()".magenta.bold }
    public static var kType: KType { .unknown }
}
