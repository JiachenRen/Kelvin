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
    
    init(_ name: String, _ args: [Node]) throws {
        self.name = name
        self.args = args
        try findDefinition()
    }
    
    private mutating func findDefinition() throws {
        if let b = BinOperator.registered[name] {
            def = {nodes in
                let values = nodes.map{$0.numericVal}
                if values.contains(nil) {return nil}
                var u = values.map{$0!}
                let r: Double = u.removeFirst()
                return u.reduce(r){b.bin($0,$1)}
            }
        } else if let u = UnaryOperator.registered[name] {
            if args.count != 1 {
                throw CompilerError.illegalArgument(errMsg: "incorrect number of arguments, \(args.count) found, 1 expected")
            }
            def = {nodes in
                if let n = nodes[0].numericVal {
                    return u(n)
                }
                return nil
            }
        }
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
}
