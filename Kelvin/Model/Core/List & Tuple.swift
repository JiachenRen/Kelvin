//
//  List & Tuple.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let listAndTupleOperations: [Operation] = [

    // Tuple operations
    .init("tuple", [.leaf, .leaf]) {
        Tuple($0[0], $0[1])
    },
    .init("get", [.tuple, .number]) { nodes in
        let tuple = nodes[0] as! Tuple
        let idx = Int(nodes[1].evaluated!.doubleValue)
        switch idx {
        case 0:
            return tuple.lhs
        case 1:
            return tuple.rhs
        default:
            return "error: index out of bounds"
        }
    },

    // List operations
    .init("list", [.universal]) {
        List($0)
    },
    .init("get", [.list, .number]) { nodes in
        let list = nodes[0] as! List
        let idx = Int(nodes[1].evaluated!.doubleValue)
        if idx >= list.count || idx < 0 {
            return "error: index out of bounds"
        } else {
            return list[idx]
        }
    },
    .init("size", [.list]) {
        return ($0[0] as! List).count
    },
    .init("map", [.list, .any]) { nodes in
        let list = nodes[0] as! List
        let updated = list.elements.enumerated().map { (idx, e) in
            nodes[1].replacingAnonymousArgs(with: [e, idx])
        }
        return List(updated)
    },
    .init("reduce", [.list, .any]) { nodes in
        let list = nodes[0] as! List
        let reduced = list.elements.reduce(nil) { (e1, e2) -> Node in
            if e1 == nil {
                return e2
            }
            return nodes[1].replacingAnonymousArgs(with: [e1!, e2])
        }
        return reduced ?? List([])
    },
]
