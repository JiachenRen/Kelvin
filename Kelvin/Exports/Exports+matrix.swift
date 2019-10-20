//
//  Exports+matrix.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let matrix: [Operation] = [
        .binary(.add, Matrix.self, Matrix.self) { (m1: Matrix, m2: Matrix) throws -> Node in
            try m1.perform({a, b in a + b}, with: m2)
        },
        .binary(.add, Matrix.self, Node.self) { (lhs, rhs) in
            lhs.transform {$0 + rhs}
        },
        .binary(.minus, Matrix.self, Matrix.self) {
            try $0.perform(-, with: $1)
        },
        .binary(.minus, Matrix.self, Node.self) {(lhs, rhs) in
            lhs.transform { $0 - rhs }
        },
        .binary(.mult, Matrix.self, Node.self) {(lhs, rhs) in
            lhs.transform { $0 * rhs }
        },
        .binary(.div, Matrix.self, Node.self) {(lhs, rhs) in
            lhs.transform { $0 / rhs }
        },
        .binary(.transform, [.node, .node]) {(a, b) in
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
        .binary(.power, Matrix.self, Int.self) {
            try $0.power($1)
        },
        .unary(.determinant, Matrix.self) {
            try $0.determinant()
        },
        .unary(.determinantCof, Matrix.self) {
            try $0.determinant(using: .cofactorExpansion)
        },
        .binary(.createMatrix, Int.self, Int.self) {
            try Matrix(rows: $0, cols: $1)
        },
        .ternary(.createMatrix, List.self, Int.self, Int.self) {
            try Matrix($0, rows: $1, cols: $2)
        },
        .unary(.createMatrix, Int.self) {
            try Matrix($0)
        },
        .unary(.identityMatrix, Int.self) {
            try Matrix.identityMatrix($0)
        },
        .unary(.transpose, Matrix.self) {
            $0.transposed()
        },
        .unary(.adjoint, Matrix.self) {
            try $0.adjoint()
        },
        .unary(.inverse, Matrix.self) {
            try $0.inverse()
        },
        .unary(.ref, Matrix.self) {
            try $0.reduce(into: .ref).mat
        },
        .unary(.rref, Matrix.self) {
            try $0.reduce(into: .rref).mat
        }
    ]
}
