//
//  OperationName+Attribute.swift
//  macOS Application
//
//  Created by Jiachen Ren on 3/2/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public extension OperationName {
    
    /// Assigning attributes to operations change their behavior during compiltion and execution.
    public enum Attribute: Hashable {
        
        /// Debugging and flow control functions like "complexity" and "repeat"
        /// should not simplify args before their execution.
        case preservesArguments
        case preservesFirstArgument
        
        /// Addition, multiplication, and boolean logic are all commutative
        /// Commutative functions with the same name should only be marked once.
        case commutative
        
        /// Operations with this flag are only commutative in the forward direction.
        /// e.g. division and subtraction.
        case forwardCommutative
        
        /// With this attribute, trailing curly brackets are forced into closures
        /// even without preceding parenthesis.
        /// e.g. code blockes like `do {}`, `deterministic {}`
        /// should be marked with `implicitTrailingClosure` attribute.
        case implicitTrailingClosure
    }
    
    /// Use this dictionary to assign special attributes to operations.
    /// e.g. since + and * are commutative, the "commutative" flag should be assigned to them.
    public static var attributes: [String: [Attribute]] = {
        defaultAttributes
    }()
    
    /// Default configurations for built-in operations.
    private static let defaultAttributes: [String: [Attribute]] = [
        .mult: [.commutative],
        .add: [.commutative],
        .and: [.commutative],
        .or: [.commutative],
        .complexity: [.preservesArguments],
        .repeat: [.preservesArguments],
        .assign: [.preservesArguments],
        .define: [.preservesArguments],
        .del: [.preservesArguments],
        .if: [.preservesArguments],
        .else: [.preservesArguments],
        .measure: [.preservesArguments, .implicitTrailingClosure],
        .try: [.preservesArguments],
        .for: [.preservesArguments],
        .while: [.preservesArguments],
        .inout: [.preservesArguments],
        .pipe: [.preservesArguments, .forwardCommutative],
        .evaluateAt: [.preservesArguments],
        .map: [.preservesArguments],
        .remove: [.preservesArguments],
        .sort: [.preservesArguments],
        .reduce: [.preservesArguments],
        .filter: [.preservesArguments],
        .transform: [.preservesArguments],
        .derivative: [.preservesArguments],
        .implicitDifferentiation: [.preservesArguments],
        .gradient: [.preservesArguments],
        .directionalDifferentiation: [.preservesArguments],
        .tangent: [.preservesArguments],
        .increment: [.preservesArguments],
        .decrement: [.preservesArguments],
        .mutatingAdd: [.preservesArguments],
        .mutatingSub: [.preservesArguments],
        .mutatingMult: [.preservesArguments],
        .mutatingDiv: [.preservesArguments],
        .mutatingConcat: [.preservesArguments],
        .div: [.forwardCommutative],
        .sub: [.forwardCommutative]
    ]
    
    /// Use subscript syntax to check if the operation contains the specified attribute.
    public subscript(attr: Attribute) -> Bool {
        return OperationName.attributes[self]?.contains(attr) ?? false
    }
}
