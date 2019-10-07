//
//  Exports+vector.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let vector: [Operation] = [
        .binary(.add, Vector.self, Vector.self) {
            try $0.perform(+, with: $1)
        },
        .binary(.add, Vector.self, Value.self) {(lhs, rhs) in
            Vector(lhs.map {$0 + rhs})
        },
        .binary(.sub, Vector.self, Vector.self) {
            try $0.perform(-, with: $1)
        },
        .binary(.sub, Vector.self, Value.self) {(lhs, rhs) in
            Vector(lhs.map {$0 - rhs})
        },
        .binary(.dotProduct, Vector.self, Vector.self) {
            try $0.dot(with: $1)
        },
        .binary(.crossProduct, Vector.self, Vector.self) {
            try $0.cross(with: $1)
        },
        .binary(.mult, Vector.self, Value.self) {(lhs, rhs) in
            Vector(lhs.map {$0 * rhs})
        },
        .binary(.div, Vector.self, Value.self) {(lhs, rhs) in
            Vector(lhs.map {$0 / rhs})
        },
        .unary(.unitVector, Vector.self) {
            $0.unitVector
        },
        .unary(.magnitude, Vector.self) {
            $0.magnitude
        },
        .binary(.angleBetween, Vector.self, Vector.self) {
            try Vector.angleBetween($0, $1)
        }
    ]
}
