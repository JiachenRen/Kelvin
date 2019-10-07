//
//  KType+Node.swift
//  Kelvin
//
//  Created by Jiachen Ren on 3/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension KType: LeafNode, NaN {
    public static var kType: KType { .type }
    public var stringified: String { KType.symbol + rawValue }
    public var ansiColored: String { rawValue.yellow }
    
    public func equals(_ node: Node) -> Bool {
        guard let dataType = node as? KType else {
            return false
        }
        return dataType == self
    }
}
