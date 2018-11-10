//
//  Operator.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/9/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

typealias Bin = (Node?, Node?) -> Node?

/**
 Binary operators such as +, -, *, /, etc.
 Supports definition of custom binary operators.
 */
class BinOperator: CustomStringConvertible {
    
    // Standard & custom binary operators
    static var registered: Dictionary<String, BinOperator> = [
        "+": .init("+", .third, +),
        "-": .init("-", .third, -),
        "*": .init("*", .second, *),
        "/": .init("/", .second, /),
        "^": .init("^", .first, ^),
        ">": .init(">", .first, >),
        "<": .init("<", .first, <),
        "%": .init("%", .second, %),
        ]
    
    
    var description: String {
        return name
    }
    
    var name: String
    var bin: Bin
    var priority: Priority
    
    private init(_ name: String, _ priority: Priority, _ bin: @escaping Bin) {
        self.priority = priority
        self.name = name;
        self.bin = bin
    }
    
    static func define(_ name: String, priority: Priority, bin: @escaping Bin) {
        let op = BinOperator(name, priority, bin)
        registered.updateValue(op, forKey: name)
    }
}

enum Priority: Int, Comparable {
    case first = 0
    case second = 1
    case third = 2
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
