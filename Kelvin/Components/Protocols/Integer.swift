//
//  Integer.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/12/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

public protocol Integer: Exact {
    var int64: Int? { get }
    var bigInt: BigInt { get }
}

// MARK: - Integer + Exact
/// Warning: These implementations might introduce inefficiency.
public extension Integer {
    var fraction: Fraction {
        Fraction(self.bigInt, 1, isReduced: true)
    }
    
    func adding(_ exact: Exact) -> Exact {
        if let i = exact as? Integer {
            return i.bigInt + bigInt
        }
        return fraction.adding(exact)
    }
    
    func subtracting(_ exact: Exact) -> Exact {
        if let i = exact as? Integer {
            return bigInt - i.bigInt
        }
        return fraction.subtracting(exact)
    }
    
    func multiplying(_ exact: Exact) -> Exact {
        if let i = exact as? Integer {
            return i.bigInt * bigInt
        }
        return fraction.multiplying(exact)
    }
    
    func dividing(_ exact: Exact) -> Exact {
        return fraction.dividing(exact)
    }
    
    func power(_ exact: Exact) -> Node? {
        return fraction.power(exact)
    }
    
    func equals(_ node: Node) -> Bool {
        guard let n = node as? Number else { return false }
        if let i = n as? Integer {
            return bigInt == i.bigInt
        }
        guard let ex = Int(exactly: n.float80) else {
            return false
        }
        return ex.bigInt == bigInt
    }
}
