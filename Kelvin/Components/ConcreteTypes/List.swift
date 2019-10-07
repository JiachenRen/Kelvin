//
//  List.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public class List: Iterable, NaN {
    public var elements: [Node]

    /// Used for copying only.
    public required init(_ elements: [Node]) {
        self.elements = elements
    }
    
    /// Combine this list with another that has the same dimension by performing
    /// a binary operation on matching pairs of elements.
    ///
    /// - Note: The two lists must have the same length!
    /// - Parameters:
    ///    - list: The list to be joined with. Each individual elements are used as rhs of bin operation.
    ///    - operation: A binary operation.
    /// - Returns: A new list resulting from self ⊗ list.
    public func joined(with list: List, by bin: String? = nil) throws -> List {
        if count != list.count {
            throw ExecutionError.dimensionMismatch(self, list)
        }
        return List(elements.enumerated().map {
            if let b = bin {
                return Function(b, [$0.element, list[$0.offset]])
            }
            return List([$0.element, list[$0.offset]])
        })
    }
    
    /// Convert every element in the list into a double.
    /// An error is thrown if not all the elements in the list is a double.
    public func toNumerics() throws -> [Float80] {
        return try elements.map {
            if let d = $0≈ {
                return d
            }
            let msg = "conversion failed - every element must be a number"
            throw ExecutionError.general(errMsg: msg)
        }
    }
    
    // MARK: - Node

    public class var kType: KType { .list }
    
    /// Check if the two lists are strictly equivalent, i.e. order does matter.
    /// - Parameter list: Another list to be compared to.
    /// - Returns: Whether self and node are equal.
    public func equals(_ node: Node) -> Bool {
        guard let list = node as? List else {
            return false
        }
        
        if list.count != count {
            return false
        }

        for i in 0..<list.elements.count {
            if self[i] !== list[i] {
                return false
            }
        }
        return true
    }
    
    public func copy() -> Self {
        return Self.init(elements.map {$0.copy()})
    }
    
    public var stringified: String {
        return "{\(concat { $0.stringified })}"
    }
    
    public var ansiColored: String {
        return "{".red.bold + "\(concat { $0.ansiColored })" + "}".red.bold
    }
}
