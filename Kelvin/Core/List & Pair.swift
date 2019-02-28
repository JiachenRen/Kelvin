//
//  List & Pair.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let listAndPairOperations: [Operation] = [
    
    .init(.add, [.list, .list]) {
        try join(by: .add, $0[0], $0[1])
    },
    .init(.add, [.list, .any]) {
        map(by: .add, $0[0], $0[1])
    },
    
    .init(.sub, [.list, .list]) {
        try join(by: .sub, $0[0], $0[1])
    },
    .init(.sub, [.list, .any]) {
        map(by: .sub, $0[0], $0[1])
    },
    
    .init(.mult, [.list, .list]) {
        try join(by: .mult, $0[0], $0[1])
    },
    .init(.mult, [.list, .any]) {
        map(by: .mult, $0[0], $0[1])
    },
    
    .init(.div, [.list, .list]) {
        try join(by: .div, $0[0], $0[1])
    },
    .init(.div, [.list, .any]) {
        map(by: .div, $0[0], $0[1])
    },
    
    .init(.exp, [.list, .list]) {
        try join(by: .exp, $0[0], $0[1])
    },
    .init(.exp, [.list, .any]) {
        map(by: .exp, $0[0], $0[1])
    },
    .binary(.exp, [.any, .list]) {
        let list = $1 as! List
        let baseList = List([Float80](repeating: $0≈!, count: list.count))
        return try join(by: .exp, baseList, list)
    },
    
    .init(.mod, [.list, .list]) {
        try join(by: .mod, $0[0], $0[1])
    },
    .init(.mod, [.list, .any]) {
        map(by: .mod, $0[0], $0[1])
    },

    // Pair operations
    .init(.pair, [.leaf, .leaf]) {
        Pair($0[0], $0[1])
    },
    .init(.get, [.pair, .number]) { nodes in
        let pair = nodes[0] as! Pair
        let idx = Int(nodes[1]≈!)
        switch idx {
        case 0:
            return pair.lhs
        case 1:
            return pair.rhs
        default:
            throw ExecutionError.indexOutOfBounds(
                Function(.get, [pair, idx]),
                maxIdx: 1,
                idx: idx
            )
        }
    },

    // List operations
    .init(.list, [.universal]) {
        List($0)
    },
    .init(.get, [.iterable, .number]) { nodes in
        let list = nodes[0] as! ListProtocol
        let idx = Int(nodes[1]≈!)
        try Assert.index(
            at: Function(.get, [list, idx]),
            list.count,
            idx
        )
        return list[idx]
    },
    .binary(.get, [.iterable, .list]) {
        let list = $0 as! ListProtocol
        let indices = try Assert.specialize(list: $1 as! ListProtocol, as: Int.self)
        
        if indices.count != 2 {
            throw ExecutionError.invalidSubscript(list, list, $1)
        }
        
        return try List(list.subsequence(from: indices[0], to: indices[1]))
    },
    .init(.size, [.iterable]) {
        return ($0[0] as! ListProtocol).count
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
    .init(.zip, [.list, .list]) {
        if let l1 = $0[0] as? List, let l2 = $0[1] as? List {
            return try l1.joined(with: l2)
        }
        return nil
    },
    .init(.append, [.list, .list]) {
        if let l1 = $0[0] as? List, let l2 = $0[1] as? List {
            let elements = [l1.elements, l2.elements].flatMap {$0}
            return List(elements)
        }
        return nil
    },
    .init(.append, [.list, .any]) {
        if let l1 = $0[0] as? List {
            let elements = [l1.elements, [$0[1]]].flatMap {$0}
            return List(elements)
        }
        return nil
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
    .binary(.contains, [.iterable, .any]) {(list, e) in
        (list as! ListProtocol).contains {
            e === $0
        }
    },
    .unary(.shuffle, [.list]) {
        var elements = ($0 as! List).elements
        elements.shuffle()
        return List(elements)
    },
    .unary(.reverse, [.list]) {
        List(($0 as! List).elements.reversed())
    }
]

fileprivate func join(by bin: String, _ l1: Node, _ l2: Node) throws -> Node {
    let l1 = l1 as! List
    let l2 = l2 as! List
    
    return try l1.joined(with: l2, by: bin)
}

fileprivate func map(by bin: String, _ l: Node, _ n: Node) -> Node {
    let l = l as! List
    
    let elements = l.map {
        Function(bin, [$0, n])
    }
    return List(elements)
}
