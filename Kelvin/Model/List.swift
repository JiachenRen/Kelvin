//
//  List.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public struct List: Node, NaN {

    var elements: [Node]

    var count: Int {
        return elements.count
    }

    /// Complexity of the list is the complexity of all its elements + 1.
    public var complexity: Int {
        return elements.reduce(0) {
            $0 + $1.complexity
        } + 1
    }

    public var stringified: String {
        let pars = elements.map {
            $0.stringified
        }.reduce(nil) {
            $0 == nil ? "\($1)" : "\($0!), \($1)"
        }
        return "{\(pars ?? "")}"
    }

    init(_ elements: [Node]) {
        self.elements = elements
    }

    init(_ elements: Node...) {
        self.init(elements)
    }

    subscript(_ idx: Int) -> Node {
        get {
            return elements[idx]
        }
        set(newValue) {
            elements[idx] = newValue
        }
    }

    /**
     Simplify each element in the list.
     
     - Returns: A copy of the list with each element simplified.
     */
    public func simplify() -> Node {
        return List(elements.map {
            $0.simplify()
        })
    }

    /// The ordering of the list does not matter, i.e. {1,2,3} is considered
    /// the same as {3,2,1}.
    /// - Returns: Whether the provided node is loosely identical to self.
    public func equals(_ node: Node) -> Bool {

        func comparator(_ lhs: Node, _ rhs: Node) -> Bool {
            return "\(lhs.stringified)" > "\(rhs.stringified)"
        }

        if let list = node as? List, list.elements.count == elements.count {
            let l1 = sorted(by: comparator)
            let l2 = list.sorted(by: comparator)
            return List.strictlyEquals(l1, l2)
        }
        return false
    }

    /**
     Split the list of elements into two groups, with the first group satisfying
     the predicament and the second group being the rest.
     
     - Parameter predicament: The condition for splitting into the first list
     - Returns: A tuple with the first element being the sublist of elements satisfying the predicament.
     */
    public func split(by predicament: PUnary) -> ([Node], [Node]) {
        var o = self.elements

        var s = [Node]()
        for (i, e) in o.enumerated() {
            if predicament(e) {
                s.append(o.remove(at: i))
            }
        }

        return (s, o)
    }

    /**
     Sort the list by using the provided comparator.
     
     - Parameter comparator: A binary function that compares two nodes.
     - Returns: A new list containing the original elements in sorted order
     */
    public func sorted(by comparator: PBinary) -> List {
        return List(elements.sorted(by: comparator))
    }

    /**
     Check if the two lists are strictly equivalent, i.e. order does matter.
     
     - Parameter lhs: A list
     - Parameter rhs: Another list to be compared to.
     - Returns: Whether lhs and rhs are strictly equivalent.
     */
    public static func strictlyEquals(_ lhs: List, _ rhs: List) -> Bool {
        if lhs.elements.count != rhs.elements.count {
            return false
        }
        for i in 0..<lhs.elements.count {
            if lhs[i] !== rhs[i] {
                return false
            }
        }
        return true
    }

    /**
     If self is the target node or any of the elements contains the target,
     then return true; otherwise return false.
     - Parameters:
        - predicament: The condition for the matching node.
        - depth: Search depth. Won't search for nodes beyond this designated depth.
     - Returns: Whether the current node contains the target node.
     */
    public func contains(where predicament: PUnary, depth: Int) -> Bool {
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

    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
                            ignores it) and returns a node as replacement.
     */
    public func replacing(by replace: Unary, where predicament: PUnary) -> Node {
        var copy = self
        copy.elements = copy.elements.map { element in
            return element.replacing(by: replace, where: predicament)
        }
        return predicament(copy) ? replace(copy) : copy
    }

    /// Perform an action on each node in the tree.
    public func forEach(_ body: (Node) -> ()) {
        body(self)
        for e in elements {
            e.forEach(body)
        }
    }

}
