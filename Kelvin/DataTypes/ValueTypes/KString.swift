//
//  Text.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/12/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct KString: LeafNode, NaN {
    
    public var stringified: String {
        return "\"\(string)\""
    }
    
    public var ansiColored: String {
        return "\"\(string)\"".green
    }
    
    public let string: String
    
    public init(_ string: String) {
        self.string = string
    }
    
    public func equals(_ node: Node) -> Bool {
        if let kString = node as? KString {
            return kString.string == string
        }
        return false
    }
    
    public func concat(_ ks: KString) -> KString {
        return KString("\(string)\(ks.string)")
    }
}
