//
//  Exports+list.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let list: [Operation] = [
        .binary(.add, Vector.self, Vector.self) {
            try $0.joined(with: $1, by: .add)
        },
        .binary(.minus, Vector.self, Vector.self) {
            try $0.joined(with: $1, by: .minus)
        },
        .binary(.mult, Vector.self, Vector.self) {
            try $0.joined(with: $1, by: .mult)
        },
        .binary(.div, Vector.self, Vector.self) {
            try $0.joined(with: $1, by: .div)
        },
        .binary(.power, Vector.self, Vector.self) {
            try $0.joined(with: $1, by: .power)
        },
        .binary(.mod, Vector.self, Vector.self) {
            try $0.joined(with: $1, by: .mod)
        },
        .init(.vector, [.init(.node, multiplicity: .any)]) {
            Vector($0)
        },
        .binary(.get, Vector.self, Node.self) {(list, n) in
            let values = list.elements.filter {
                if let key = ($0 as? Pair)?.lhs {
                    return key === n
                }
                return false
            }.map {
                ($0 as! Pair).rhs
            }
            return values.count == 1 ? values[0] : Vector(values)
        },
        .binary(.zip, Vector.self, Vector.self) {
            try $0.joined(with: $1)
        },
        .binary(.append, Vector.self, Vector.self) {
            Vector([$0.elements, $1.elements].flatMap { $0 })
        },
    ]
}
