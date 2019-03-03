//
//  Statements.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Pipeline: MutableListProtocol, NaN {
    
    public var precedence: Keyword.Precedence {
        return .pipeline
    }
    
    public var elements: [Node]
    
    public var stringified: String {
        let statements: String? = elements.reduce(nil) {
            $0 == nil ? $1.stringified : $0! + "; " + $1.stringified
        }
        return statements ?? ""
    }
    
    public var ansiColored: String {
        let statements: String? = elements.reduce(nil) {
            $0 == nil ? $1.ansiColored : $0! + "; ".bold + $1.ansiColored
        }
        return statements ?? ""
    }
    
    init(_ statements: [Node]) {
        self.elements = statements
    }
    
    public func equals(_ node: Node) -> Bool {
        if let pipeline = node as? Pipeline {
            return equals(list: pipeline)
        }
        return false
    }
    
    public func simplify() throws -> Node {
        do {
            return try elements.map {try $0.simplify()}.last ?? KVoid()
        } catch let e as KelvinError {
            throw ExecutionError.onNode(self, err: e)
        }
    }
}
