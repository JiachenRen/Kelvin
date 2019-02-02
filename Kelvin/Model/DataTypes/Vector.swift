//
//  Vector.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Vector: MutableListProtocol, NaN {
    
    var elements: [Node]
    
    var magnitude: Node {
        return √(++elements.map {$0 ^ 2})
    }
    
    var unitVector: Vector {
        let mag = magnitude
        return Vector(elements.map {$0 / mag})
    }
    
    public var stringified: String {
        let e = elements.reduce(nil) {
            $0 == nil ? $1.stringified : "\($0!), \($1.stringified)"
        } ?? ""
        return "[\(e)]"
    }
    
    init(_ components: [Node]) {
        self.elements = components
    }
    
    init?(_ node: Node) {
        if let list = node as? ListProtocol {
            self.elements = list.elements
        } else {
            return nil
        }
    }
    
    public func equals(_ node: Node) -> Bool {
        if let v = node as? Vector {
            return equals(list: v)
        }
        return false
    }
    
    /**
     Perform an operation with another vector.
     e.g. [a b] + [c d] = [a+c b+d]
     
     - Warning: Do not use * and / as it would cause confusion with
     the definition of dot product!
     */
    public func perform(_ operation: Binary, with vec: Vector) throws -> Vector {
        if vec.count != count {
            throw ExecutionError.dimensionMismatch
        }
        
        let elements = zip(self.elements, vec.elements).map {
            operation($0, $1)
        }
        
        return Vector(elements)
    }
    
    /**
     Calculate the dot product of this vector with the target vector.
     u1 = <a1, b1, c1, ...n1>,
     u2 = <a2, b2, c2, ...n2>,
     u1 • u2 = a1 * a2 + b1 * b2 + ... + n1 * n2.
     */
    public func dot(with vec: Vector) throws -> Node {
        if vec.count != count {
            throw ExecutionError.dimensionMismatch
        }
        
        return zip(elements, vec.elements).map {
            $0 * $1
        }.reduce(0) {
            $0 + $1
        }
    }
    
    /**
     Perform cross product with target vector.
     
     - Note: Only works for vectors of two or three dimensions.
     */
    public func cross(with vec: Vector) throws -> Vector {
        if count != vec.count {
            throw ExecutionError.dimensionMismatch
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
        var copy = self
        copy.elements.append(element)
        return copy
    }
    
    public func truncatingLast() -> Vector {
        var copy = self
        copy.elements.removeLast()
        return copy
    }
    
    /// - Returns: Angle between v1 and v2 in radians
    public static func angleBetween(_ v1: Vector, _ v2: Vector) throws -> Node {
        return try acos(v1.unitVector.dot(with: v2.unitVector))
    }
}
