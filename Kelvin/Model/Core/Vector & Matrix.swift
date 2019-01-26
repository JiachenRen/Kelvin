//
//  Vector & Matrix.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let vectorOperations: [Operation] = [
    .init("+", [.vec, .vec]) {
        try v($0[0]).perform(+, with: v($0[1]))
    },
    .init("+", [.vec, .number]) { nodes in
        Vector(v(nodes[0]).map {$0 + nodes[1]})
    },
    .init("-", [.vec, .vec]) {
        try v($0[0]).perform(-, with: v($0[1]))
    },
    .init("-", [.vec, .number]) { nodes in
        Vector(v(nodes[0]).map {$0 - nodes[1]})
    },
    .init("dotP", [.vec, .vec]) {
        try v($0[0]).dot(with: v($0[1]))
    },
    .init("*", [.vec, .number]) { nodes in
        Vector(v(nodes[0]).map {$0 * nodes[1]})
    },
    .init("/", [.vec, .number]) { nodes in
        Vector(v(nodes[0]).map {$0 / nodes[1]})
    },
    .init("unitVec", [.vec]) {
        return v($0[0]).unitVector
    },
    .init("mag", [.vec]) {
        return v($0[0]).magnitude
    }
]

let matrixOperations: [Operation] = [
    .init("det", [.matrix]) {
        return try m($0[0]).determinant()
    },
    .init("mat", [.int, .int]) {
        Matrix(rows: i($0[0]), cols: i($0[1]))
    },
    .init("mat", [.int]) {
        Matrix(i($0[0]))
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
