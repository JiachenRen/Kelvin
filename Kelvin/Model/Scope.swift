//
//  Scope.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/21/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Scope {
    
    /// An array that keeps track of variable definitions and operations.
    private static var stack = [Scope]()
    
    private var definitions: [String: Node]
    private var operations: [String: [Operation]]
    
    init(_ definitions: [String: Node], _ operations: [String: [Operation]]) {
        self.definitions = definitions
        self.operations = operations
    }
    
    /**
     Capture and save current scope - that is, all variable definitions,
     operations, and function definitions.
     */
    public static func save() {
        let curScope = Scope(Variable.definitions, Operation.registered)
        stack.append(curScope)
    }
    
    /**
     Restore to default operations, variable & constant definitions.
     */
    public static func restoreDefault() {
        Variable.restoreDefault()
        Operation.restoreDefault()
    }
    
    /**
     Pop the last saved scope from the stack and use it as a blueprint
     to restore function and variable definitions.
     */
    public static func restore() {
        let scope = stack.removeLast()
        Operation.registered = scope.operations
        Variable.definitions = scope.definitions
    }
    
    /// Discard last saved scope
    @discardableResult
    public static func popLast() -> Scope {
        return stack.removeLast()
    }
}
