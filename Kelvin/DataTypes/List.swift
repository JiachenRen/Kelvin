//
//  List.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public struct List: MutableListProtocol, NaN {

    public var elements: [Node]

    public var stringified: String {
        let pars = elements.map {
            $0.stringified
        }.reduce(nil) {
            $0 == nil ? "\($1)" : "\($0!), \($1)"
        }
        return "{\(pars ?? "")}"
    }
    
    public var ansiColored: String {
        let pars = elements.map {
            $0.ansiColored
            }.reduce(nil) {
                $0 == nil ? "\($1)" : "\($0!), \($1)"
        }
        return "{".red.bold + "\(pars ?? "")" + "}".red.bold
    }
    
    public var precedence: Keyword.Precedence {
        return .node
    }

    init(_ elements: [Node]) {
        self.elements = elements
    }

    init(_ elements: Node...) {
        self.init(elements)
    }
    
    init?(_ node: Node) {
        if let list = node as? ListProtocol {
            self.elements = list.elements
        } else if let str = node as? KString {
            self.elements = str.string.map {KString("\($0)")}
        } else {
            return nil
        }
    }

    /// The ordering of the list does not matter, i.e. {1,2,3} is considered
    /// the same as {3,2,1}.
    /// - Returns: Whether the provided node is loosely identical to self.
    public func equals(_ node: Node) -> Bool {
        if let l = node as? List {
            return ordered().equals(list: l.ordered() as ListProtocol)
        }
        return false
    }
    
    /**
     Combine this list with another that has the same dimension by performing
     a binary operation on matching pairs of elements.
     
     - Note: The two lists must have the same length!
     - Parameters:
        - list: The list to be joined with. Each individual elements are used as rhs of bin operation.
        - operation: A binary operation.
     - Returns: A new list resulting from self ⊗ list.
     */
    public func joined(with list: List, by bin: String? = nil) throws -> List {
        if count != list.count {
            throw ExecutionError.dimensionMismatch(self, list)
        }
        return List(elements.enumerated().map {
            if let b = bin {
                return Function(b, [$0.element, list[$0.offset]])
            }
            return List($0.element, list[$0.offset])
        })
    }
    
    public func removing(at idx: Int) throws -> List {
        try Assert.index(count, idx)
        var list = self
        list.elements.remove(at: idx)
        return list
    }

    /**
     Sort the list by using the provided comparator.
     
     - Parameter comparator: A binary function that compares two nodes.
     - Returns: A new list containing the original elements in sorted order
     */
    public func sorted(by comparator: (Node, Node) throws -> Bool) rethrows -> List {
        return List(try elements.sorted(by: comparator))
    }
    
    /**
     Order the list according to their String
     representations.
     
     - Returns: A new list w/ elements sorted in natural order.
     */
    public func ordered() -> List {
        return sorted {(e1, e2) in
            return e1.stringified < e2.stringified
        }
    }
    
    /**
     Convert every element in the list into a double.
     An error is thrown if not all the elements in the list is a double.
     */
    public func toNumerics() throws -> [Float80] {
        return try elements.map {
            if let d = $0≈ {
                return d
            }
            let msg = "conversion failed - every element must be a number"
            throw ExecutionError.general(errMsg: msg)
        }
    }
}
