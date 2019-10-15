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
        .binary(.add, List.self, List.self) {
            try $0.joined(with: $1, by: .add)
        },
        .binary(.sub, List.self, List.self) {
            try $0.joined(with: $1, by: .sub)
        },
        .binary(.mult, List.self, List.self) {
            try $0.joined(with: $1, by: .mult)
        },
        .binary(.div, List.self, List.self) {
            try $0.joined(with: $1, by: .div)
        },
        .binary(.power, List.self, List.self) {
            try $0.joined(with: $1, by: .power)
        },
        .binary(.mod, List.self, List.self) {
            try $0.joined(with: $1, by: .mod)
        },
        .init(.list, [.init(.node, multiplicity: .any)]) {
            List($0)
        },
        .binary(.get, List.self, Node.self) {(list, n) in
            let values = list.elements.filter {
                if let key = ($0 as? Pair)?.lhs {
                    return key === n
                }
                return false
            }.map {
                ($0 as! Pair).rhs
            }
            return values.count == 1 ? values[0] : List(values)
        },
        .binary(.zip, List.self, List.self) {
            try $0.joined(with: $1)
        },
        .binary(.append, List.self, List.self) {
            List([$0.elements, $1.elements].flatMap { $0 })
        },
    ]
}
