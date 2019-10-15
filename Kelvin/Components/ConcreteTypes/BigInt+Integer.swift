//
//  BigInt+Number.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/11/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

extension BigInt: Integer {
    public var float80: Float80 {
        if let exact = Float80(exactly: self) {
            return exact
        }
        Program.shared.io?.warning("precision maybe compromised - big integer -> float80")
        return Float80(self)
    }
    public var sign: BigInt { self == 0 ? 0 : self > 0 ? 1 : -1 }
    public var ansiColored: String { description.bold.blue }
    public var int64: Int? { Int(exactly: self) }
    public var bigInt: BigInt { self }
    public func simplify() -> Node { Int(exactly: self) ?? self }
    public func negate() -> BigInt { -self }
    public func abs() -> BigInt { self > 0 ? self : -self }
}
