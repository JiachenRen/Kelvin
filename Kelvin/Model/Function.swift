//
//  Function.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

typealias Definition = ([Node]) -> Node?
struct Function: Node {
    var numericVal: Double? {
        return invoke()?.numericVal
    }
    
    var name: String
    var args: [Node]
    
    var def: Definition?
    
    var description: String {
        return "\(name)(\(List(args)))"
    }
    
    func invoke() -> Node? {
        return def?(args)
    }
    
    func simplify() -> Node {
        if let result = invoke() {
            return result
        } else {
            var copy = self
            copy.args = args.map{$0.simplify()}
            return copy
        }
    }
    
    private mutating func findDefinition() {
        if let bin = BinOperator.registered[name] {
            def = {nodes in
                var nodes = nodes
                var result: Node = nodes.removeFirst()
                for node in nodes {
                    if let partial = bin.bin(result, node) {
                        result = partial
                    } else {
                        return nil
                    }
                }
                return result
            }
        }
    }
    
    init(_ name: String, _ args: [Node]) {
        self.name = name
        self.args = args
        findDefinition()
    }
    
}
