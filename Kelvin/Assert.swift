//
//  Assert.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/27/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Assert {
    public static func domain(_ x: Value, _ lb: Value, _ ub: Value) throws {
        if x≈! < lb≈! || x≈! > ub≈!  {
            throw ExecutionError.domain(
                x,
                lowerBound: lb,
                upperBound: ub)
        }
    }
    
    public static func range(_ lb: Value, _ ub: Value) throws {
        if lb≈! > ub≈! {
            throw ExecutionError.invalidRange(
                lowerBound: lb,
                upperBound: ub)
        }
    }
    
    public static func index(_ count: Int, _ idx: Int) throws {
        if idx >= count || idx < 0 {
            throw ExecutionError.indexOutOfBounds(
                maxIdx: count - 1,
                idx: idx
            )
        }
    }
    
    public static func squareMatrix(_ mat: Matrix) throws {
        if !mat.isSquareMatrix {
            throw ExecutionError.nonSquareMatrix
        }
    }
    
    public static func dimension(_ mat1: Matrix, _ mat2: Matrix) throws {
        if mat1.dim != mat2.dim {
            throw ExecutionError.dimensionMismatch(mat1, mat2)
        }
    }
    
    public static func cast<T>(_ node: Node?, to type: T.Type) throws -> T {
        guard let instance = node as? T else {
            throw try ExecutionError.unexpectedType(
                expected: .resolve(type),
                found: .resolve(node ?? KVoid())
            )
        }
        return instance
    }
    
    public static func specialize<T>(list: ListProtocol, as type: T.Type) throws -> [T] {
        return try list.map {(n: Node) throws -> T in
            if let e = n as? T {
                return e
            }
            throw try ExecutionError.unexpectedType(
                expected: .resolve(type),
                found: .resolve(n)
            )
        }
    }
    
    public static func dataType(_ typeLiteral: String) throws -> DataType {
        guard let t1 = DataType(rawValue: typeLiteral) else {
            throw ExecutionError.invalidType(invalidTypeLiteral: typeLiteral)
        }
        return t1
    }
}
