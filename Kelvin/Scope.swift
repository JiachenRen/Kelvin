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
    
    public var definitions: [String: Node]
    public var operations: [String: [Operation]]
    private static var restricted = [String: Node]()
    
    public static var current: Scope {
        return Scope(Variable.definitions, Operation.registered)
    }
    
    init(_ definitions: [String: Node], _ operations: [String: [Operation]]) {
        self.definitions = definitions
        self.operations = operations
    }
    
    /**
     Capture and save current scope - that is, all variable definitions,
     operations, and function definitions.
     */
    public static func save() {
        stack.append(current)
    }
    
    /**
     Restore to default operations, variable & constant definitions.
     */
    public static func restoreDefault() {
        Variable.restoreDefault()
        Operation.restoreDefault()
    }
    
    public func apply() {
        Operation.registered = operations
        Variable.definitions = definitions
    }
    
    /**
     Pop the last saved scope from the stack and use it as a blueprint
     to restore function and variable definitions.
     */
    public static func restore() {
        stack.removeLast().apply()
    }
    
    /// Discard last saved scope
    @discardableResult
    public static func popLast() -> Scope {
        return stack.removeLast()
    }
    
    /**
     Temporarily withhold any attempts to access the variable.
     */
    public static func withholdAccess(to vars: Variable...) {
        vars.forEach {v in
            let n = v.name
            if let def = Variable.definitions[n] {
                restricted[n] = def
                Variable.definitions.removeValue(forKey: n)
            }
        }
    }
    
    public static func withholdAccess(to vars: [Variable]) {
        vars.forEach {withholdAccess(to: $0)}
    }
    
    public static func releaseRestrictions() {
        for (key, value) in restricted {
            Variable.define(key, value)
        }
        restricted.removeAll()
    }
}
