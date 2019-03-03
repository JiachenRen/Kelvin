//
//  List & Pair.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let listAndPairOperations: [Operation] = [
    .binary(.add, List.self, List.self) {
        try $0.joined(with: $1, by: .add)
    },
    .binary(.add, List.self, Node.self) {
        map(by: .add, $0, $1)
    },
    
    .binary(.sub, List.self, List.self) {
        try $0.joined(with: $1, by: .sub)
    },
    .binary(.sub, List.self, Node.self) {
        map(by: .sub, $0, $1)
    },
    
    .binary(.mult, List.self, List.self) {
        try $0.joined(with: $1, by: .mult)
    },
    .binary(.mult, List.self, Node.self) {
        map(by: .mult, $0, $1)
    },
    
    .binary(.div, List.self, List.self) {
        try $0.joined(with: $1, by: .div)
    },
    .binary(.div, List.self, Node.self) {
        map(by: .div, $0, $1)
    },
    
    .binary(.exp, List.self, List.self) {
        try $0.joined(with: $1, by: .exp)
    },
    .binary(.exp, List.self, Node.self) {
        map(by: .exp, $0, $1)
    },
    .binary(.exp, Node.self, List.self) {(base, list) in
        let baseList = List([Node](repeating: base, count: list.count))
        return try baseList.joined(with: list, by: .exp)
    },
    
    .binary(.mod, List.self, List.self) {
        try $0.joined(with: $1, by: .mod)
    },
    .binary(.mod, List.self, Node.self) {
        map(by: .mod, $0, $1)
    },

    // Pair operations
    .binary(.pair, [.any, .any]) {
        Pair($0, $1)
    },
    .binary(.get, Pair.self, Int.self) {(pair, idx) in
        switch idx {
        case 0:
            return pair.lhs
        case 1:
            return pair.rhs
        default:
            throw ExecutionError.indexOutOfBounds(
                nil,
                maxIdx: 1,
                idx: idx
            )
        }
    },

    // List operations
    .init(.list, [.universal]) {
        List($0)
    },
    .binary(.get, ListProtocol.self, Int.self) {(list, idx) in
        try Assert.index(list.count, idx)
        return list[idx]
    },
    .binary(.get, List.self, Node.self) {(list, n) in
        let values = list.elements.filter {
            if let key = ($0 as? Pair)?.lhs {
                return key === n
            }
            return false
        }.map {
            ($0 as! Pair).rhs
        }
        return values.count == 1 ? values[0] : List(values)
    },
    .binary(.get, ListProtocol.self, List.self) {(list, idxList) in
        let indices = try Assert.specialize(list: idxList, as: Int.self)
        guard indices.count == 2 else {
            throw ExecutionError.invalidSubscript(nil, list, idxList)
        }
        return try List(list.subsequence(from: indices[0], to: indices[1]))
    },
    .unary(.size, ListProtocol.self) {
        return $0.count
    },
    .init(.map, [.any, .any]) { nodes in
        var list = try Assert.cast(nodes[0].simplify(), to: MutableListProtocol.self)
        let updated = list.elements.enumerated().map { (idx, e) in
            nodes[1].replacingAnonymousArgs(with: [e, idx])
        }
        list.elements = updated
        return list
    },
    .init(.reduce, [.any, .any]) { nodes in
        let list = try Assert.cast(nodes[0].simplify(), to: List.self)
        let reduced = list.elements.reduce(nil) { (e1, e2) -> Node in
            if e1 == nil {
                return e2
            }
            return nodes[1].replacingAnonymousArgs(with: [e1!, e2])
        }
        return reduced ?? List([])
    },
    .init(.filter, [.any, .any]) { nodes in
        let list = try Assert.cast(nodes[0].simplify(), to: List.self)
        let updated = try list.elements.enumerated().map {(idx, e) in
                nodes[1].replacingAnonymousArgs(with: [e, idx])
            }.enumerated().map {(idx, predicate) in
                let b = try Assert.cast(predicate.simplify(), to: Bool.self)
                return b ? idx : nil
            }.compactMap {
                $0 == nil ? nil: list[$0!]
            }
        return List(updated)
    },
    .binary(.zip, List.self, List.self) {
        try $0.joined(with: $1)
    },
    .binary(.append, List.self, List.self) {
        List([$0.elements, $1.elements].flatMap {$0})
    },
    .binary(.append, List.self, Node.self) {
        List([$0.elements, [$1]].flatMap {$0})
    },
    .init(.sort, [.any, .any]) {nodes in
        var l1 = try Assert.cast(nodes[0].simplify(), to: List.self)
        return try l1.sorted {
            let predicate = try nodes[1].replacingAnonymousArgs(with: [$0, $1])
                .simplify()
            return try Assert.cast(predicate, to: Bool.self)
        }
    },
    .binary(.remove, [.any, .any]) {(l, n) in
        var list = try Assert.cast(l.simplify(), to: List.self)
        if let idx = try n.simplify() as? Int {
            return try list.removing(at: idx)
        } else {
            try list.elements.removeAll {e in
                let predicate = n.replacingAnonymousArgs(with: [e])
                return try Assert.cast(predicate, to: Bool.self)
            }
            return list
        }
    },
    .binary(.contains, ListProtocol.self, Node.self) {(list, e) in
        list.contains {e === $0}
    },
    .unary(.shuffle, List.self) {
        var elements = $0.elements
        elements.shuffle()
        return List(elements)
    },
    .unary(.reverse, List.self) {
        List($0.elements.reversed())
    }
]

fileprivate func map(by bin: String, _ l: List, _ n: Node) -> Node {
    let elements = l.map {
        Function(bin, [$0, n])
    }
    return List(elements)
}
