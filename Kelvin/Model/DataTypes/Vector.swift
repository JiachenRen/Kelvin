//
//  Vector.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

struct Vector: MutableListProtocol, NaN {
    
    var elements: [Node]
    
    var stringified: String {
        let e = elements.reduce(nil) {
            $0 == nil ? $1 : "\($0!), \($1)"
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
    
    func equals(_ node: Node) -> Bool {
        if let v = node as? Vector {
            return equals(list: v)
        }
        return false
    }
    
    /**
     Perform an operation with another vector.
     e.g. [a b] dot [c d] = [a*c b*d]
     */
    func perform(_ operation: Binary, with vec: Vector) throws -> Vector {
        if vec.count != count {
            throw ExecutionError.dimensionMismatch
        }
        
        let elements = zip(self.elements, vec.elements).map {
            operation($0, $1)
        }
        
        return Vector(elements)
    }
    
    /**
     Perform cross product with target vector.
     [a b] cross [c d] = [a*c b*d]
     
     // TODO: Implement
     */
    func cross(with vec: Vector) throws -> Vector {
        throw ExecutionError.general(errMsg: "not implemented")
    }
}
