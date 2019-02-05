//
//  Closure.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// TODO: retention policy
public struct Closure: UnaryNode, NaN {
    
    public static var symbol = "#"
    var capturesReturn: Bool

    public var stringified: String {
        return "#(\(node.stringified))"
    }
    
    var node: Node
    
    init(_ definition: Node, capturesReturn: Bool = false) {
        self.node = definition
        self.capturesReturn = capturesReturn
    }

    public var ansiColored: String {
        return "#(".magenta.bold + node.ansiColored + ")".magenta.bold
    }

    public var complexity: Int {
        return node.complexity + 1
    }

    public func simplify() throws -> Node {
        do {
            let result = try node.simplify()
            return result
        } catch let e as Transfer {
            switch e {
            case .return(let n) where capturesReturn:
                return n
            default:
                throw e
            }
        }
    }

    public func equals(_ node: Node) -> Bool {
        if let closure = node as? Closure {
            return node === closure.node
        }
        return false
    }
}
