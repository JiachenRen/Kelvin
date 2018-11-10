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
        if let b = BinOperator.registered[name] {
            def = {nodes in
                let values = nodes.map{$0.numericVal}
                if values.contains(nil) {return nil}
                var u = values.map{$0!}
                let r: Double = u.removeFirst()
                return u.reduce(r){b.bin($0,$1)}
            }
        } else if let u = UnaryOperator.registered[name] {
            def = {nodes in
                if nodes.count != 1 {
                    fatalError() // Replace with RuntimeError.arguments
                } else if let n = nodes[0].numericVal {
                    return u(n)
                }
                return nil
            }
        }
    }
    
    init(_ name: String, _ args: [Node]) {
        self.name = name
        self.args = args
        findDefinition()
    }
    
}
