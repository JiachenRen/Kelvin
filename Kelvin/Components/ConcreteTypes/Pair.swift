//
//  Pair.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/18/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Pair: Iterable, BinaryNode {
    public var stringified: String { concat(by: " \(preposition.rawValue) ") { $0.stringified } }
    public var ansiColored: String { concat(by: " \(preposition.rawValue) ") { $0.ansiColored } }
    public var precedence: Keyword.Precedence { .pair }
    public var elements: [Node]
    
    /// Preposition binding the pair of nodes.
    public var preposition: Preposition
    
    /// Preposition is syntax syntactic surgar used to improve readability of code.
    public enum Preposition: String, CaseIterable {
        case of, to, from, at, into, colon = ":"
    }
    
    /// Grammar for prepositions, i.e. syntactic constructs
    /// `insert @node at @int of @listProtocol`
    /// `set @int of @listProtocol to @node`
    /// `set @string(option) to @string(value)`
    static let grammar: [OperationName: [[Preposition]: (Pair) throws -> Function]] = [
        .insert: [
            [.at, .of]: { pair in
                try applyAsArgs(.insert, pair) { args in
                    try args[1] ~> Int.self
                    try args[2] ~> ListProtocol.self
                }
            }
        ],
        .set: [
            [.of, .to]: { pair in
                try applyAsArgs(.set, pair) { args in
                    let i = try args[0] ~> Int.self
                    let list = try args[1] ~> ListProtocol.self
                }
            },
            [.to]: { pair in
                try pair.lhs ~> String.self
                try pair.rhs ~> String.self
                return Function(.set, pair.elements)
            },
        ],
        .swap: [
            [.of]: { pair in
                try pair.lhs ~> List.self
                try pair.rhs ~> ListProtocol.self
                return Function(.swap, pair.elements)
            }
        ]
    ]
    
    /// Invoke operation whose name is `name` using elements of `pair` as arguments,
    /// meanwhile ensuring that provided `precondition` is satisfied.
    private static func applyAsArgs(
        _ name: OperationName,
        _ pair: Pair,
        precondition: ([Node]) throws -> Void
    ) throws -> Function {
        let args = pair.flattened()
        try precondition(args)
        return Function(name, args)
    }
    
    public required init(_ v1: Node, _ v2: Node, preposition: Preposition = .colon) {
        self.elements = [v1, v2]
        self.preposition = preposition
    }
    
    /// Checks if the preposition list of this pair matches the provided list of prepositions.
    public func matches(_ prepList: [Preposition]) -> Bool {
        return prepositionList() == prepList
    }
    
    /// Recursively finds the prepositions used for this pair of nodes.
    /// e.g. `3 of list from 5 to 10 -> [.of, .from, .to]`
    public func prepositionList() -> [Preposition] {
        var left = (lhs as? Pair)?.prepositionList() ?? []
        let right = (rhs as? Pair)?.prepositionList() ?? []
        left.append(preposition)
        left.append(contentsOf: right)
        return left
    }
    
    /// Flattens the binary tree of pairs into a list of nodes.
    public func flattened() -> [Node] {
        var left = (lhs as? Pair)?.flattened() ?? [lhs]
        let right = (rhs as? Pair)?.flattened() ?? [rhs]
        left.append(contentsOf: right)
        return left
    }
    
    public func equals(_ other: Node) -> Bool {
        guard let pair = other as? Pair else {
            return false
        }
        return equals(list: pair)
    }
    
    public func copy() -> Self {
        return Self(lhs, rhs, preposition: preposition)
    }
}
