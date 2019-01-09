//
//  Number.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation


public protocol Value: Leaf {
    func doubleValue() -> Double
}

extension Value {
    public var evaluated: Value? {
        return self
    }
    
    public func equals(_ node: Node) -> Bool {
        if let d = node as? Value {
            return d.doubleValue() == doubleValue()
        }
        return false
    }
}

extension Double: Value {
    var isInteger: Bool {
        return floor(self) == self
    }
    
    public func doubleValue() -> Double {
        return self
    }
}

extension Int: Value {
    public func doubleValue() -> Double {
        return Double(self)
    }
}

extension Bool: Value {
    public func doubleValue() -> Double {
        return Double(self ? 1 : 0)
    }
}
