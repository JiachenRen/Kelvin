//
//  Statements.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/4/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public final class Statements: ListProtocol {
    public class var kType: KType { .unknown }
    public var elements: [Node]
    public var precedence: Keyword.Precedence { .pipeline }
    public var stringified: String { concat(by: "; ") { $0.stringified } }
    public var ansiColored: String { concat(by: "; ".bold) { $0.ansiColored } }
    
    public init(_ elements: [Node]) {
        self.elements = elements
    }
    
    public func equals(_ node: Node) -> Bool {
        if let statements = node as? Statements {
            return equals(list: statements)
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
    
    public func copy() -> Self {
        return Self(elements.map { $0.copy() })
    }
}
