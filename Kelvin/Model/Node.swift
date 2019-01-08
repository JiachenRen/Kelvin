//
//  Node.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol Node: CustomStringConvertible {
    
    /// Computes the numerical value that the node represents.
    var numericalVal: Double? {get}
    
    /// Simplifies the node.
    func simplify() -> Node
    
    /// Formats the expression for ease of computation
    /// - Convert all subtraction to addition + negation
    /// - Convert all division to multiplifications
    /// - Flatten binary operation trees. i.e. (a+b)+c becomes a+b+c
    func format() -> Node
    
    /// Convert all subtractions to additions
    func toAdditionOnlyForm() -> Node
    
    /// Convert all divisions to multiplifications and exponentiations
    func toExponentialForm() -> Node
    
    /// Flatten binary operation trees
    func flatten() -> Node
}

extension Node {
    public func format() -> Node {
        return self.toAdditionOnlyForm()
            .toExponentialForm()
            .flatten()
    }
}


