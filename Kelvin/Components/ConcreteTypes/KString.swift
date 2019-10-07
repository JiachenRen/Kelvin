//
//  KString.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/12/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class KString: LeafNode, NaN {
    public var stringified: String { "\"\(string)\"" }
    public var ansiColored: String { "\"\(string)\"".green }
    public class var kType: KType { .string }
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
