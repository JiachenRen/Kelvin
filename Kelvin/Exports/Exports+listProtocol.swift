//
//  Exports+listProtocol.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/21/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let listProtocol: [Operation] = [
        .binary(.get, ListProtocol.self, Int.self) {(iterable, idx) in
            try Assert.index(iterable.count, idx)
            return iterable[idx]
        },
        .binary(.get, ListProtocol.self, List.self) {(list, idxList) in
            let indices = try Assert.specialize(list: idxList, as: Int.self)
            guard indices.count == 2 else {
                throw ExecutionError.invalidSubscript(list, idxList)
            }
            return try List(list.sublist(from: indices[0], to: indices[1]))
        },
        .ternary(.set, Int.self, ListProtocol.self, Node.self) {
            (i, list, e) in
            var list = list
            list[i] = e
            return list
        },
        .unary(.count, ListProtocol.self) {
            return $0.count
        },
        .init(.map, [.node, .node]) { nodes in
            let list = try nodes[0].simplify() ~> ListProtocol.self
            let updated = list.elements.enumerated().map { (idx, e) in
                nodes[1].replacingAnonymousArgs(with: [e, idx])
            }
            list.elements = updated
            return list
        },
        .init(.reduce, [.node, .node]) { nodes in
            let list = try nodes[0].simplify() ~> ListProtocol.self
            let reduced = list.elements.reduce(nil) { (e1, e2) -> Node in
                if e1 == nil {
                    return e2
                }
                return nodes[1].replacingAnonymousArgs(with: [e1!, e2])
            }
            return reduced ?? KVoid()
        },
        .init(.filter, [.node, .node]) { nodes in
            var list = try nodes[0].simplify() ~> ListProtocol.self
            let updated = try list.elements.enumerated().map {(idx, e) in
                    nodes[1].replacingAnonymousArgs(with: [e, idx])
                }.enumerated().map {(idx, predicate) in
                    let b = try predicate.simplify() ~> Bool.self
                    return b ? idx : nil
                }.compactMap {
                    $0 == nil ? nil: list[$0!]
                }
            list.elements = updated
            return list
        },
        .binary(.append, ListProtocol.self, Node.self) {
            var copy = $0.copy()
            copy.elements.append($1)
            return copy
        },
        .init(.sort, [.node, .node]) {nodes in
            let l1 = try nodes[0].simplify() ~> ListProtocol.self
            return try l1.sorted {
                let predicate = try nodes[1].replacingAnonymousArgs(with: [$0, $1])
                    .simplify()
                return try predicate ~> Bool.self
            }
        },
        .binary(.removeAll, [.node, .node]) {(l, n) in
            let list = try l.simplify() ~> ListProtocol.self
            try list.elements.removeAll {e in
                let predicate = n.replacingAnonymousArgs(with: [e])
                return try predicate.simplify() ~> Bool.self
            }
            return list
        },
        .binary(.remove, ListProtocol.self, Int.self) {(l, n) in
            try l.removing(at: n)
        },
        .binary(.contains, ListProtocol.self, Node.self) {(list, e) in
            list.contains {e === $0}
        },
        .unary(.shuffle, ListProtocol.self) {
            var list = $0.copy()
            list.elements.shuffle()
            return list
        },
        .unary(.reverse, ListProtocol.self) {
            var list = $0.copy()
            list.elements.reverse()
            return list
        },
        .ternary(.insert, Node.self, Int.self, ListProtocol.self) {
                (e, i, list) in
            try Assert.index(list.count + 1, i)
            list.elements.insert(e, at: i)
            return list
        },
    ]
}
