//
//  MutableListProtocol.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/20/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

protocol MutableListProtocol: ListProtocol {
    var elements: [Node] { get set }
}

extension MutableListProtocol {
    
    /**
     Replace the designated nodes identical to the node provided with the replacement
     
     - Parameter predicament: The condition that needs to be met for a node to be replaced
     - Parameter replace:   A function that takes the old node as input (and perhaps
     ignores it) and returns a node as replacement.
     */
    public func replacing(by replace: (Node) throws -> Node, where predicament: PUnary) rethrows -> Node {
        var copy = self
        copy.elements = try copy.elements.map { element in
            return try element.replacing(by: replace, where: predicament)
        }
        return predicament(copy) ? try replace(copy) : copy
    }
    
    /**
     Simplify each element in the list.
     
     - Returns: A copy of the list with each element simplified.
     */
    public func simplify() throws -> Node {
        var copy = self
        do {
            copy.elements = try elements.map {
                try $0.simplify()
            }
        } catch let e as KelvinError {
            throw ExecutionError.onNode(self, err: e)
        }
        return copy
    }
    
    subscript(_ idx: Int) -> Node {
        get {
            return elements[idx]
        }
        set(newValue) {
            elements[idx] = newValue
        }
    }
}
