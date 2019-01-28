//
//  Vector & Matrix.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let vectorOperations: [Operation] = [
    .binary(.add, [.vec, .vec]) {
        try v($0).perform(+, with: v($1))
    },
    .binary(.add, [.vec, .number]) {(lhs, rhs) in
        Vector(v(lhs).map {$0 + rhs})
    },
    .binary(.sub, [.vec, .vec]) {
        try v($0).perform(-, with: v($1))
    },
    .binary(.sub, [.vec, .number]) {(lhs, rhs) in
        Vector(v(lhs).map {$0 - rhs})
    },
    .binary(.dotProduct, [.vec, .vec]) {
        try v($0).dot(with: v($1))
    },
    .binary(.crossProduct, [.vec, .vec]) {
        try v($0).cross(with: v($1))
    },
    .binary(.mult, [.vec, .number]) {(lhs, rhs) in
        Vector(v(lhs).map {$0 * rhs})
    },
    .binary(.div, [.vec, .number]) {(lhs, rhs) in
        Vector(v(lhs).map {$0 / rhs})
    },
    .unary(.unitVector, [.vec]) {
        return v($0).unitVector
    },
    .unary(.magnitude, [.vec]) {
        return v($0).magnitude
    }
]

let matrixOperations: [Operation] = [
    .binary(.add, [.matrix, .matrix]) {
        try m($0).perform(+, with: m($1))
    },
    .binary(.add, [.matrix, .any]) {(lhs, rhs) in
        m(lhs).performOnEach {$0 + rhs}
    },
    .binary(.sub, [.matrix, .matrix]) {
        try m($0).perform(-, with: m($1))
    },
    .binary(.sub, [.matrix, .any]) {(lhs, rhs) in
        m(lhs).performOnEach {$0 - rhs}
    },
    .binary(.mult, [.matrix, .any]) {(lhs, rhs) in
        m(lhs).performOnEach {$0 * rhs}
    },
    .binary(.div, [.matrix, .any]) {(lhs, rhs) in
        m(lhs).performOnEach {$0 / rhs}
    },
    .binary(.matrixMultiplication, [.matrix, .matrix]) {
        try m($0).mult(m($1))
    },
    .unary(.determinant, [.matrix]) {
        return try m($0).determinant()
    },
    .binary(.createMatrix, [.int, .int]) {
        Matrix(rows: i($0), cols: i($1))
    },
    .unary(.createMatrix, [.int]) {
        Matrix(i($0))
    },
    .unary(.identityMatrix, [.int]) {
        Matrix.identityMatrix(i($0))
    },
    .unary(.invertMatrix, [.matrix]) {
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
