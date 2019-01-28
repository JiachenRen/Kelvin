//
//  Vector & Matrix.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let vectorOperations: [Operation] = [
    .binary("+", [.vec, .vec]) {
        try v($0).perform(+, with: v($1))
    },
    .binary("+", [.vec, .number]) {(lhs, rhs) in
        Vector(v(lhs).map {$0 + rhs})
    },
    .binary("-", [.vec, .vec]) {
        try v($0).perform(-, with: v($1))
    },
    .binary("-", [.vec, .number]) {(lhs, rhs) in
        Vector(v(lhs).map {$0 - rhs})
    },
    .binary("dotP", [.vec, .vec]) {
        try v($0).dot(with: v($1))
    },
    .binary("crossP", [.vec, .vec]) {
        try v($0).cross(with: v($1))
    },
    .binary("*", [.vec, .number]) {(lhs, rhs) in
        Vector(v(lhs).map {$0 * rhs})
    },
    .binary("/", [.vec, .number]) {(lhs, rhs) in
        Vector(v(lhs).map {$0 / rhs})
    },
    .unary("unitVec", [.vec]) {
        return v($0).unitVector
    },
    .unary("mag", [.vec]) {
        return v($0).magnitude
    }
]

let matrixOperations: [Operation] = [
    .binary("+", [.matrix, .matrix]) {
        try m($0).perform(+, with: m($1))
    },
    .binary("+", [.matrix, .any]) {(lhs, rhs) in
        m(lhs).performOnEach {$0 + rhs}
    },
    .binary("-", [.matrix, .matrix]) {
        try m($0).perform(-, with: m($1))
    },
    .binary("-", [.matrix, .any]) {(lhs, rhs) in
        m(lhs).performOnEach {$0 - rhs}
    },
    .binary("*", [.matrix, .any]) {(lhs, rhs) in
        m(lhs).performOnEach {$0 * rhs}
    },
    .binary("/", [.matrix, .any]) {(lhs, rhs) in
        m(lhs).performOnEach {$0 / rhs}
    },
    .binary("mult", [.matrix, .matrix]) {
        try m($0).mult(m($1))
    },
    .unary("det", [.matrix]) {
        return try m($0).determinant()
    },
    .binary("mat", [.int, .int]) {
        Matrix(rows: i($0), cols: i($1))
    },
    .unary("mat", [.int]) {
        Matrix(i($0))
    },
    .unary("idMat", [.int]) {
        Matrix.identityMatrix(i($0))
    },
    .unary("invert", [.matrix]) {
        m($0).inverted
    }
]

fileprivate func v(_ node: Node) -> Vector {
    return node as! Vector
}

fileprivate func m(_ node: Node) -> Matrix {
    return node as! Matrix
}

fileprivate func i(_ node: Node) -> Int {
    return node as! Int
}
