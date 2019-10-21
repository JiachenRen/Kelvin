//
//  Exports+iterable.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let iterable: [Operation] = [
        .binary(.add, Iterable.self, Node.self) {
            applyToEach(.add, $0, $1)
        },
        .binary(.minus, Iterable.self, Node.self) {
            applyToEach(.minus, $0, $1)
        },
        .binary(.mult, Iterable.self, Node.self) {
            applyToEach(.mult, $0, $1)
        },
        .binary(.div, Iterable.self, Node.self) {
            applyToEach(.div, $0, $1)
        },
        .binary(.power, Iterable.self, Node.self) {
            applyToEach(.power, $0, $1)
        },
        .binary(.mod, Iterable.self, Node.self) {
            applyToEach(.mod, $0, $1)
        },
        
        .unary(.flatten, Iterable.self) {
            var copy = $0.copy()
            var flattened: [Node] = []
            copy.elements.forEach { e in
                if let l = e as? Iterable {
                    flattened.append(contentsOf: l.elements)
                    return
                }
                flattened.append(e)
            }
            copy.elements = flattened
            return copy
        }
    ]
}

fileprivate func applyToEach(_ bin: String, _ l: Iterable, _ n: Node) -> Node {
    let copy = l.copy()
    let elements = l.map {
        Function(bin, [$0, n])
    }
    copy.elements = elements
    return copy
}
