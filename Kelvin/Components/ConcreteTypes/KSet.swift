//
//  KSet.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class KSet: Iterable, NaN {
    public var elements: [Node] {
        get { items.map { $0.node } }
        set { items = Set(newValue.map { Item($0) }) }
    }
    
    public var stringified: String { "{\(concat { $0.stringified })}" }
    
    public var ansiColored: String { "{".red.bold + "\(concat { $0.ansiColored })" + "}".red.bold }
    
    var items: Set<Item>
    
    init(_ elements: [Node]) {
        items = Set(elements.map { Item($0) })
    }
    
    public func copy() -> Self {
        return self
    }
    
    public func equals(_ node: Node) -> Bool {
        guard let set = node as? KSet else {
            return false
        }
        return set.items == items
    }
    
    public class Item: Hashable {
        let node: Node
        private let tag: String
        
        init(_ node: Node) {
            self.node = node
            self.tag = node.stringified
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(tag)
        }
        
        public static func == (lhs: KSet.Item, rhs: KSet.Item) -> Bool {
            return lhs.node === rhs.node
        }
    }
}
