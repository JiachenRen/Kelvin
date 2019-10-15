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
    ///     - x: Number to be checked against bounds
    ///     - lb: Lower bound
    ///     - ub: Upper bound
    /// - Throws: `ExecutionError.domain`
    public static func domain(_ x: Number, _ lb: Number, _ ub: Number) throws {
        if x≈! < lb≈! || x≈! > ub≈!  {
            throw ExecutionError.domain(x, lowerBound: lb, upperBound: ub)
        }
    }
    
    /// Asserts that the given number of rows and cols form a valid dimension.
    /// That is, `rows > 0 && cols > 0`.
    /// - Throws: `.invalidDimension` if either `rows` or `cols` is less than 0.
    public static func validDimension(rows r: Int, cols c: Int) throws {
        if r < 1 || c < 1 {
            throw ExecutionError.invalidDimension(rows: r, cols: c)
        }
    }
    
    /// Asserts that `lb` ad `ub` form a valid range. That is, `lb < ub`.
    /// - Parameters:
    ///     - lb: Lower bound
    ///     - ub: Upper bound
    /// - Throws: `ExecutionError.invalidRange`
    public static func range(_ lb: Number, _ ub: Number) throws {
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
            throw ExecutionError.unexpectedType(
                expected: .resolve(T.self),
                found: KType.resolve(node ?? KVoid())
            )
        }
        return instance
    }
    
    /// Specializes the type erased `list` in Kelvin into an array of specified type `T`
    /// - Parameters:
    ///     - list: A `ListProtocl`
    ///     - type: Swift Type used to specialize the list.
    /// - Throws: `ExecutionError.unexpectedType` if the list contains types other than `T`
    public static func specialize<T>(list: ListProtocol, as type: T.Type) throws -> [T] {
        return try list.map {(n: Node) throws -> T in
            try cast(n, to: T.self)
        }
    }
    
    /// Asserts that the given matrix is non-singular, otherwise an eror is thrown.
    /// - Throws: `ExecutionError.singularMatrix`
    public static func nonSingular(_ mat: Matrix) throws {
        if try !mat.isSingular() {
            throw ExecutionError.singularMatrix
        }
    }
    
    /// Specializes the type erased `matrix` in Kelvin into a 2D array of specified type `T`
    /// - Parameters:
    ///     - mat: A `Matrix`.
    ///     - type: Swift Type used to specialize the list.
    /// - Throws: `ExecutionError.unexpectedType` if the list contains types other than `T`
    public func specialize<T: Node>(mat: Matrix, as type: T.Type) throws -> [[T]] {
        return try mat.rows.map {row in
            try row.map { e in
                try Assert.cast(e, to: T.self)
            }
        }
    }
    
    /// Asserts that the every list in `lists` has the same length.
    /// - Throws: `.nonUniform` if any list has a different length.
    public static func uniform(_ lists: [ListProtocol]) throws {
        for i in 0..<lists.count - 1 {
            if lists[i].count != lists[i + 1].count {
                throw ExecutionError.nonUniform
            }
        }
    }
}
