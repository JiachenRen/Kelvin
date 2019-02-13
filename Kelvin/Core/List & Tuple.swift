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
        let baseList = List([Double](repeating: $0≈!, count: list.count))
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
                idx: idx)
        }
    },

    // List operations
    .init(.list, [.universal]) {
        List($0)
    },
    .init(.get, [.iterable, .number]) { nodes in
        let list = nodes[0] as! ListProtocol
        let idx = Int(nodes[1]≈!)
        if idx >= list.count || idx < 0 {
            throw ExecutionError.indexOutOfBounds(
                Function(.get, [list, idx]),
                maxIdx: list.count - 1,
                idx: idx)
        } else {
            return list[idx]
        }
    },
    .binary(.get, [.iterable, .list]) {
        let list = $0 as! ListProtocol
        let indices = try ($1 as! List).map {(n: Node) throws -> Int in
            if let i = n as? Int {
                return i
            }
            throw ExecutionError.unexpectedType(n, expected: .int, found: try .resolve(n))
        }
        
        if indices.count != 2 {
            throw ExecutionError.invalidSubscript(list, list, $1)
        }
        
        return try List(list.subsequence(from: indices[0], to: indices[1]))
    },
    .init(.size, [.iterable]) {
        return ($0[0] as! ListProtocol).count
    },
    .init(.map, [.any, .any]) { nodes in
        guard var list = try nodes[0].simplify() as? MutableListProtocol else {
            return nil
        }
        let updated = try list.elements.enumerated().map { (idx, e) in
            try nodes[1].replacingAnonymousArgs(with: [e, idx]).simplify()
        }
        list.elements = updated
        return list
    },
    .init(.reduce, [.any, .any]) { nodes in
        guard let list = try nodes[0].simplify() as? List else {
            return nil
        }
        let reduced = try list.elements.reduce(nil) { (e1, e2) -> Node in
            if e1 == nil {
                return e2
            }
            return try nodes[1].replacingAnonymousArgs(with: [e1!, e2]).simplify()
        }
        return reduced ?? List([])
    },
    .init(.filter, [.any, .any]) { nodes in
        guard let list = try nodes[0].simplify() as? List else {
            return nil
        }
        let updated = try list.elements.enumerated().map {(idx, e) in
                nodes[1].replacingAnonymousArgs(with: [e, idx])
            }.enumerated().map {(idx, predicate) in
                if let b = try predicate.simplify() as? Bool {
                    return b ? idx : nil
                }
                throw ExecutionError.unexpectedType(
                    Function(.filter, nodes),
                    expected: .bool,
                    found: try .resolve(predicate.simplify()))
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
    .init(.sort, [.list, .any]) {nodes in
        if let l1 = nodes[0] as? List {
            return try l1.sorted {
                let predicate = try nodes[1].replacingAnonymousArgs(with: [$0, $1]).simplify()
                if let b = predicate as? Bool {
                    return b
                }
                throw ExecutionError.unexpectedType(
                    Function(.filter, nodes),
                    expected: .bool,
                    found: try .resolve(predicate.simplify()))
            }
        }
        return nil
    },
    .binary(.removeAtIdx, [.list, .int]) {
        try ($0 as! List).removing(at: $1 as! Int)
    },
    .unary(.shuffle, [.list]) {
        var elements = ($0 as! List).elements
        elements.shuffle()
        return List(elements)
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
