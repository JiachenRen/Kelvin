//
//  Vector & Matrix.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class LinearAlgebra {
    
    public static let operations: [Operation] = [
        matrixOperations,
        vectorOperations
    ].flatMap {$0}
    
    static let matrixOperations: [Operation] = [
        .binary(.add, Matrix.self, Matrix.self) {
            try $0.perform(+, with: $1)
        },
        .binary(.add, Matrix.self, Node.self) {(lhs, rhs) in
            lhs.transform {$0 + rhs}
        },
        .binary(.sub, Matrix.self, Matrix.self) {
            try $0.perform(-, with: $1)
        },
        .binary(.sub, Matrix.self, Node.self) {(lhs, rhs) in
            lhs.transform {$0 - rhs}
        },
        .binary(.mult, Matrix.self, Node.self) {(lhs, rhs) in
            lhs.transform {$0 * rhs}
        },
        .binary(.div, Matrix.self, Node.self) {(lhs, rhs) in
            lhs.transform {$0 / rhs}
        },
        .binary(.transform, [.any, .any]) {(a, b) in
            let mat = try Assert.cast(a.simplify(), to: Matrix.self)
            return mat.transform {(cell: Matrix.Cell) -> Node in
                b.replacingAnonymousArgs(with: [cell.node, cell.row, cell.col])
            }
        },
        .unary(.cofactor, Matrix.self) {
            try Assert.cast($0, to: Matrix.self).cofactorMatrix()
        },
        .ternary(.cofactor, [.matrix, .int, .int]) {
            let r = try Assert.cast($1, to: Int.self)
            let c = try Assert.cast($2, to: Int.self)
            return try Assert.cast($0, to: Matrix.self)
                .cofactor(row: r, col: c)
        },
        .binary(.matrixMultiplication, Matrix.self, Matrix.self) {
            try $0.mult($1)
        },
        .unary(.determinant, Matrix.self) {
            try $0.determinant()
        },
        .binary(.createMatrix, Int.self, Int.self) {
            Matrix(rows: $0, cols: $1)
        },
        .unary(.createMatrix, Int.self) {
            Matrix($0)
        },
        .unary(.identityMatrix, Int.self) {
            Matrix.identityMatrix($0)
        },
        .unary(.transpose, Matrix.self) {
            $0.transposed
        },
        .unary(.gaussianElimination, Matrix.self) {
            try gaussianElimination($0)
        }
    ]
    
    static let vectorOperations: [Operation] = [
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
