//
//  CallStack.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/10/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class StackTrace {
    public private(set) var instructions: [Instruction]
    public var isEnabled: Bool = false
    public var debugOn: Bool = false
    private var indentLevel = 0
    
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
    
    /// The action that the instruction performed.
    enum Action: String {
        case push, pop
    }
    
    /// History of stack trace consist of operations; each operation contains
    /// the instruction, the node for which the instruction is being applied,
    /// and an additional info that is specified by each node.
    public struct Instruction: CustomStringConvertible {
        let action: Action
        let target: String?
        let node: Node?
        
        public var description: String {
            return "- \(action.rawValue.uppercased())(\(target ?? "NONE")) \(node?.stringified ?? "NONE")"
        }
        
        init(_ action: Action, _ node: Node?, _ target: String?) {
            self.action = action
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
        instructions = [Instruction]()
    }
    
    /// Adds a new operation to stack trace if stack trace is enabled, excluding ignored
    ///
    /// - Parameter node: The node for which the instruction is acting upon
    /// - Parameter instr: Action taken for the instruction
    /// - Parameter target: Description for the target of invocation
    func add(_ action: Action, _ node: Node? = nil, _ target: String? = nil) {
        if !isEnabled || (
            target != nil
            && (ignoredSysOps.contains(target!) || untracked.contains(target!))
        ) {
            return
        }
        let op = Instruction(action, node, target)
        instructions.append(op)
        if debugOn {
            if action == .pop {
                indentLevel -= 1
            }
            print(pad(for: indentLevel) + op.description)
            if action == .push {
                indentLevel += 1
            }
        }
    }
    
    private func pad(for indent: Int, using whitespace: String = "  ") -> String {
        return repeatElement(whitespace, count: indent)
            .reduce("") {$0 + $1}
    }
    
    /// Generate a stack trace string from operations.
    /// - Parameter padding: Tabs or spaces used to pad each pop/push operation
    /// - Returns: A neatly formatted, properly indented string that represents the stack trace
    public func genStackTrace(padding: String = "  ") -> String {
        var indent = 0
        return instructions.reduce("") { (trace, op) in
            if op.action == .pop {
                indent -= 1
            }
            let s = pad(for: indent, using: padding) + op.description + "\n"
            if op.action == .push {
                indent += 1
            }
            return trace + s
        }
    }
    
    /// Clears the stack trace history until this point.
    public func clear() {
        instructions = []
        indentLevel = 0
    }
    
}
