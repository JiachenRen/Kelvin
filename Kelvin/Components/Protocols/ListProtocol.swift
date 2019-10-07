//
//  ListProtocol.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol ListProtocol: AnyObject, Node, NaN {
    var elements: [Node] { get set }
}

public extension ListProtocol {
    var precedence: Keyword.Precedence { .node }
    var count: Int { elements.count }
    
    /// Complexity of the list is the complexity of all its elements + 1.
    var complexity: Int {
        elements.reduce(1) { $0 + $1.complexity }
    }
    
    /// Checks if the provided index is out of bounds of this list.
    func isOutOfBounds(_ idx: Int) -> Bool {
        idx < 0 || idx >= count
    }
    
    /// - Parameters:
    ///     - extractor: Used to convert a node to string.
    ///     - separator: The separator between each element.
    /// - Returns: A string by concatenating all elements with the provided separator
    func concat(by separator: String = ", ", _ extractor: (Node) -> String) -> String {
        elements.map(extractor)
            .reduce(nil) {
            $0 == nil ? "\($1)" : "\($0!)\(separator)\($1)"
        } ?? ""
    }
    
    /// - Returns: A sublist from `idx1` to `idx2`
    func sublist(from idx1: Int, to idx2: Int) throws -> [Node] {
        try Assert.index(count, idx1)
        try Assert.index(count, idx2)
        try Assert.range(idx1, idx2)
        return Array(elements.suffix(from: idx1)
            .prefix(upTo: idx2 - idx1 + 1))
    }
    
    /// Perform an action on each node in the tree.
    func forEach(_ body: (Node) -> ()) {
        body(self)
        for e in elements {
            e.forEach(body)
        }
    }
    
    /// Checks if self is the target node or any of the elements contains the target.
    /// - Parameters:
    ///     - predicament: The condition for the matching node.
    ///     - depth: Search depth. Won't search for nodes beyond this designated depth.
    /// - Returns: True if current node contains target node, otherwise false.
    func contains(where predicament: PUnary, depth: Int) -> Bool {
        if predicament(self) {
            return true
        } else if depth != 0 {
            for e in elements {
                if e.contains(where: predicament, depth: depth - 1) {
                    return true
                }
            }
        }
        return false
    }
    
    func contains(where predicament: PUnary) -> Bool {
        elements.contains(where: predicament)
    }
    
    /// Sorts the list by using the provided comparator.
    /// - Parameter comparator: A binary function that compares two nodes.
    func sort(by comparator: (Node, Node) throws -> Bool) rethrows {
        try elements.sort(by: comparator)
    }
    
    /// - Parameter comparator: A binary function that compares two nodes.
    /// - Returns: A new list containing the original elements in sorted order.
    func sorted(by comparator: (Node, Node) throws -> Bool) rethrows -> List {
        List(try elements.sorted(by: comparator))
    }
    
    /// Order elements in the list according to their String representations.
    func order() {
        sort {(e1, e2) in
            e1.stringified < e2.stringified
        }
    }
    
    /// - Returns: A new list w/ elements sorted in natural order.
    func ordered() -> List {
        sorted {(e1, e2) in
            e1.stringified < e2.stringified
        }
    }
    
    /// Maps the elements of this list into `[T]`.
    func map<T>(by unary: (Node) throws -> T) rethrows -> [T] {
        try elements.map(unary)
    }
    
    /// Replace the nodes identical to the node provided with the replacement.
    /// - Parameter predicament: The condition that needs to be met for a node to be replaced.
    /// - Parameter replace: A function that takes the old node as input (and perhaps ignores it) and returns a node as replacement.
    func replacing(by replace: (Node) throws -> Node, where predicament: PUnary) rethrows -> Node {
        let copy = self.copy()
        copy.elements = try copy.elements.map { element in
            return try element.replacing(by: replace, where: predicament)
        }
        return predicament(copy) ? try replace(copy) : copy
    }
    
    func removing(at idx: Int) throws -> ListProtocol {
        try Assert.index(count, idx)
        let list = self.copy()
        list.elements.remove(at: idx)
        return list
    }
    
    /// Split the list of elements into two groups, with the first group satisfying
    /// the predicament and the second group being the rest.
    ///
    /// - Parameter predicament: The condition for splitting into the first list
    /// - Returns: A tuple with the first element being the sublist of elements satisfying the predicament.
    func split(by predicament: PUnary) -> ([Node], [Node]) {
        var o = self.elements
        var s = [Node]()
        for (i, e) in o.enumerated() {
            if predicament(e) {
                s.append(o.remove(at: i))
            }
        }
        return (s, o)
    }
    
    /// Checks if elements in `list` are equal to elements in self.
    func equals(list: ListProtocol) -> Bool {
        if list.count != count {
            return false
        }
        for (i, e) in elements.enumerated() {
            if e !== list[i] {
                return false
            }
        }
        return true
    }
    
    /// Checks if the two lists contain the same elements. Order does not matter
    func looselyEquals(_ other: ListProtocol) -> Bool {
        ordered().equals(other.ordered())
    }
    
    /// Simplify each element in the list.
    /// - Returns: A copy of the list with each element simplified.
    func simplify() throws -> Node {
        let copy = self.copy()
        do {
            copy.elements = try elements.map {
                try $0.simplify()
            }
        } catch let e as KelvinError {
            throw ExecutionError.onNode(self, err: e)
        }
        return copy
    }
    
    /// Subscript getter/setter.
    subscript(_ idx: Int) -> Node {
        get {
            return elements[idx]
        }
        set(newValue) {
            elements[idx] = newValue
        }
    }
}
