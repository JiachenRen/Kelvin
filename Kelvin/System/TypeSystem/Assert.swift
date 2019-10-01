//
//  Assert.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/27/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// `Assert` is used to ensure that certain conditions are met before certain operations can be executed.
/// It provides a standardized way of handling errors and unexpected input values in Kelvin.
public class Assert {
    
    /// Asserts that the given value `x` is between `lb` and `ub`
    /// - Parameters:
    ///     - x: Value to be checked against bounds
    ///     - lb: Lower bound
    ///     - ub: Upper bound
    /// - Throws: `ExecutionError.domain`
    public static func domain(_ x: Value, _ lb: Value, _ ub: Value) throws {
        if x≈! < lb≈! || x≈! > ub≈!  {
            throw ExecutionError.domain(x, lowerBound: lb, upperBound: ub)
        }
    }
    
    /// Asserts that `lb` ad `ub` form a valid range. That is, `lb < ub`.
    /// - Parameters:
    ///     - lb: Lower bound
    ///     - ub: Upper bound
    /// - Throws: `ExecutionError.invalidRange`
    public static func range(_ lb: Value, _ ub: Value) throws {
        if lb≈! > ub≈! {
            throw ExecutionError.invalidRange(lowerBound: lb, upperBound: ub)
        }
    }
    
    /// Asserts that the given `idx` is within the domain `[0,count)`
    /// - Parameters:
    ///     - count: Number of elements in the array
    ///     - idx: Index for accessing the array
    /// - Throws: `ExecutionError.indexOutOfBounds`
    public static func index(_ count: Int, _ idx: Int) throws {
        if idx >= count || idx < 0 {
            throw ExecutionError.indexOutOfBounds(maxIdx: count - 1, idx: idx)
        }
    }
    
    /// Asserts that the given matrix is a square matrix.
    /// - Throws: `ExecutionError.nonSquareMatrix`
    public static func squareMatrix(_ mat: Matrix) throws {
        if !mat.isSquareMatrix {
            throw ExecutionError.nonSquareMatrix
        }
    }
    
    /// Asserts that `mat1` and  `mat2` have the same dimension.
    /// - Throws: `ExecutionError.dimensionMismatch`
    public static func dimension(_ mat1: Matrix, _ mat2: Matrix) throws {
        if mat1.dim != mat2.dim {
            throw ExecutionError.dimensionMismatch(mat1, mat2)
        }
    }
    
    /// Casts the given node to specified Swift type, otherwise throw type cast exception.
    /// - Throws: `ExecutionError.unexpectedType`
    public static func cast<T>(_ node: Node?, to type: T.Type) throws -> T {
        guard let instance = node as? T else {
            throw try ExecutionError.unexpectedType(
                expected: .resolve(type),
                found: .resolve(node ?? KVoid())
            )
        }
        return instance
    }
    
    /// Specializes the type erased `list` in Kelvin into an array of specified type `T`
    /// - Parameters:
    ///     - list: A list in Kelvin.
    ///     - type: Swift Type used to specialize the list.
    /// - Throws: `ExecutionError.unexpectedType` if the list contains types other than `T`
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
}
