//
//  Conversion.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

let conversionOperations: [Operation] = [
    .init("degrees", [.any]) {
        $0[0] / 180 * (try! Variable("pi"))
    },
    .init("pct", [.any]) {
        $0[0] / 100
    },
    
    // TODO: Implement all possible type coersions.
    .init("as", [.any, .var]) {nodes in
        let n = nodes[1] as! Variable
        guard let dt = DataType(rawValue: n.name) else {
            throw ExecutionError.invalidDT(n.name)
        }
        
        func bailOut() throws {
            throw ExecutionError.inconvertibleDT(from: "\(nodes[0])", to: dt.rawValue)
        }
        
        switch dt {
        case .list:
            if let list = List(nodes[0]) {
                return list
            }
            try bailOut()
        case .vector:
            if let vec = Vector(nodes[0]) {
                return vec
            }
            try bailOut()
        default:
            break
        }
    
        return nil
    }
]
