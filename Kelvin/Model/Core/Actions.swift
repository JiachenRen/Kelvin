//
//  Actions.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

// Variable/function definition and deletion
let actionOperations: [Operation] = [
    .init("def", [.equation]) { nodes in
        if let err = (nodes[0] as? Equation)?.define() {
            return err
        }
        return "done"
    },
    .init("define", [.any, .any]) { nodes in
        return Function("def", [Equation(lhs: nodes[0], rhs: nodes[1])])
    },
    .init("del", [.var]) { nodes in
        if let v = nodes[0] as? Variable {
            Variable.delete(v.name)
            Operation.remove(v.name)
            return "deleted '\(v.stringified)'"
        }
        return nil
    }
]

