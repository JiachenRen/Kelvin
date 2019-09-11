//
//  CallStack.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/10/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class StackTrace {
    public private(set) var operations: [Operation]
    public var isEnabled: Bool = false
    
    /// List of function to be untracked accessible to the user
    public var untracked: [String] = []
    
    /// Special system calls to be ignored, e.g. APIs in kelvin that make use of Stack Trace,
    /// special constrol functions related to loop and flow control
    private let ignoredSysOps: [String] = [
        .setStackTraceEnabled,
        .printStackTrace,
        .clearStackTrace,
        .setStackTraceUntracked,
        .break,
        .return,
        .throw,
        .continue
    ]
    
    /// Instruction for the operation
    enum Instruction: String {
        case push, pop
    }
    
    /// History of stack trace consist of operations; each operation contains
    /// the instruction, the node for which the instruction is being applied,
    /// and an additional info that is specified by each node.
    public struct Operation: CustomStringConvertible {
        let instr: Instruction
        let target: String?
        let node: Node?
        
        public var description: String {
            return "- \(instr.rawValue.uppercased())(\(target ?? "NONE")) \(node?.stringified ?? "NONE")"
        }
        
        init(_ instr: Instruction, _ node: Node?, _ target: String?) {
            self.instr = instr
            self.node = node
            self.target = target
        }
    }
    
    /// Shared singleton instance of CallStack.
    public static var shared: StackTrace = {
        return StackTrace()
    }()
    
    /// Instantiates a new StackTrace object.
    init() {
        operations = [Operation]()
    }
    
    /// Adds a new operation to stack trace if stack trace is enabled, excluding ignored
    ///
    /// - Parameter node: The node for which the instruction is acting upon
    /// - Parameter instr: Instruction taken for the operation
    /// - Parameter target: Description for the target of invocation
    func add(_ instr: Instruction, _ node: Node? = nil, _ target: String? = nil) {
        if !isEnabled || (
            target != nil
            && (ignoredSysOps.contains(target!) || untracked.contains(target!))
        ) {
            return
        }
        operations.append(Operation(instr, node, target))
    }
    
    /// Generate a stack trace string from operations.
    /// - Parameter padding: Tabs or spaces used to pad each pop/push operation
    /// - Returns: A neatly formatted, properly indented string that represents the stack trace
    public func genStackTrace(padding: String = "  ") -> String {
        var indent = 0
        return operations.reduce("") { (trace, op) in
            if op.instr == .pop {
                indent -= 1
            }
            let s = repeatElement(padding, count: indent)
                .reduce("") {$0 + $1} + op.description + "\n"
            if op.instr == .push {
                indent += 1
            }
            return trace + s
        }
    }
    
    /// Clears the stack trace history until this point.
    public func clear() {
        operations = []
    }
    
}
