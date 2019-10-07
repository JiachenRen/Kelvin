//
//  Closure.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Closure: UnaryNode, NaN {
    public static var symbol = "$"
    public var node: Node
    var capturesReturn: Bool
    
    public required init(_ node: Node, capturesReturn: Bool = false) {
        self.node = node
        self.capturesReturn = capturesReturn
    }
    
    convenience init?(_ list: List) {
        if list.count == 1 {
            self.init(list[0])
        } else {
            return nil
        }
    }
    
    public var stringified: String {
        "\(Closure.symbol)(\(node.stringified))"
    }

    public var ansiColored: String {
        return "\(Closure.symbol)(".magenta.bold + node.ansiColored + ")".magenta.bold
    }
    
    public class var kType: KType { .unknown }

    public func simplify() throws -> Node {
        do {
            let result = try node.simplify()
            return result
        } catch let e as FlowControl {
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
    
    public func copy() -> Self {
        Self.init(node.copy(), capturesReturn: capturesReturn)
    }
}
