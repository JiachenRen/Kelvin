//
//  Vector.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Vector: Iterable {
    public var elements: [Node]
    public var magnitude: Node {
        √(++elements.map {$0 ^ 2})
    }
    
    public var unitVector: Vector {
        Vector(elements.map { $0 / magnitude })
    }
    
    public required init(_ components: [Node]) {
        self.elements = components
    }
    
    public convenience init(_ list: ListProtocol) {
        self.init(list.elements)
    }

    public convenience init(_ mat: Matrix) throws {
        try Assert.equals(mat.dim.cols, 1)
        self.init(mat.rows.compactMap { $0[0] })
    }
    /// Perform an operation with another vecto;. e.g. `[a b] + [c d] = [a+c b+d]`
    /// - Warning: Do not use `*` and `/` as it would cause confusion with the definition of dot product!
    public func perform(_ operation: Binary, with vec: Vector) throws -> Vector {
        if vec.count != count {
            throw ExecutionError.dimensionMismatch(self, vec)
        }
        
        let elements = zip(self.elements, vec.elements).map {
            operation($0, $1)
        }
        
        return Vector(elements)
    }
    
    /// Calculate the dot product of this vector with the target vector.
    /// `u1 = <a1, b1, c1, ...n1>`,
    /// `u2 = <a2, b2, c2, ...n2>`,
    /// `u1 • u2 = a1 * a2 + b1 * b2 + ... + n1 * n2`.
    public func dot(with vec: Vector) throws -> Node {
        try Assert.dimension(self, vec)
        return try zip(elements, vec.elements)
            .map { $0 * $1 }
            .reduce(0) { $0 + $1 }
            .simplify()
    }
    
    /// The projection of vector `a` onto `b` is `(a•b)/(b•b)*b`
    /// - Returns: The vector obtained by projecting a onto b.
    public func project(onto vec: Vector) throws -> Vector {
        try Assert.dimension(self, vec)
        return try ((self.dot(with: vec) / vec.dot(with: vec)) * vec)
            .simplify() as! Vector
    }
    
    /// Perform cross product with target vector.
    /// - Note: Only works for vectors of two or three dimensions.
    public func cross(with vec: Vector) throws -> Vector {
        if count != vec.count {
            throw ExecutionError.dimensionMismatch(self, vec)
        } else if count == 2 {
            return try appending(0)
                .cross(with: vec.appending(0))
        } else if count != 3 {
            let msg = "can only calculate cross product of vectors of dimension 2, 3"
            throw ExecutionError.general(errMsg: msg)
        }
        
        let i = vec[2] * self[1] - vec[1] * self[2]
        let j = vec[0] * self[2] - vec[2] * self[0]
        let k = vec[1] * self[0] - vec[0] * self[1]
        return Vector([i, j, k])
    }
    
    public func appending(_ element: Node) -> Vector {
        let copy = self.copy()
        copy.elements.append(element)
        return copy
    }
    
    public func truncatingLast() -> Vector {
        let copy = self.copy()
        copy.elements.removeLast()
        return copy
    }
    
    /// - Returns: Angle between v1 and v2 in radians
    public static func angleBetween(_ v1: Vector, _ v2: Vector) throws -> Node {
        return try acos(v1.unitVector.dot(with: v2.unitVector))
    }
    
    /// Finds the orthogonal basis of the given set of vectors using the **Gram-Schmidt** method.
    /// - Returns: The orthogonal basis of the given set of basis.
    public static func orthogonalBasis(of basis: [Vector]) throws -> [Vector] {
        try Assert.uniform(basis)
        var basis = basis
        var orthBasis = [Vector]()
        while(basis.count > 0) {
            var x = basis.removeFirst()
            for v in orthBasis {
                x = try (x - x.project(onto: v)).simplify() as! Vector
            }
            orthBasis.append(x)
        }
        return orthBasis
    }
    
    // MARK: - Node
    
    public func equals(_ other: Node) -> Bool {
        guard let vec = other as? Vector else {
            return false
        }
        return equals(list: vec)
    }
    
    public func copy() -> Self {
        return Self(elements.map { $0.copy() })
    }
    
    public var stringified: String { "[\(concat { $0.stringified })]" }
    public var ansiColored: String { "[".red.bold + "\(concat { $0.ansiColored })" + "]".red.bold }
    public var minimal: String { concat(by: " ") { $0.stringified } }
}
