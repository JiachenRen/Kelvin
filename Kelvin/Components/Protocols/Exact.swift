//
//  Exact.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/14/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol Exact: Number {
    var fraction: Fraction { get }
    func adding(_ exact: Exact) -> Exact
    func subtracting(_ exact: Exact) -> Exact
    func multiplying(_ exact: Exact) -> Exact
    func dividing(_ exact: Exact) -> Exact
    func power(_ exact: Exact) -> Node?
    func negate() -> Self
    func abs() -> Self
}
