//
//  ConsoleViewController+IOProtocol.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/8/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension ConsoleViewController: IOProtocol {
    
    private func format(_ n: Node) -> String {
        if let ks = n as? KString {
            return ks.string
        }
        return n.stringified
    }
    
    private func append(to buffer: Buffer, _ content: String) {
        buffers[buffer] = (buffers[buffer] ?? "") + content
    }
    
    func print(_ n: Node) {
        append(to: .console, format(n))
    }
    
    func println(_ n: Node) {
        append(to: .console, format(n) + "\n")
    }
    
    func log(_ l: String) {
        append(to: .debugger, l + "\n")
    }
    
    func log(_ l: Program.Log) {
        append(to: .debugger, "\t← \(format(l.input))\n")
        append(to: .debugger, "\t→ \(format(l.output))\n")
    }
    
    func error(_ e: String) {
        append(to: .debugger, e)
    }
    
    func clear() {
        buffers[.debugger] = ""
        buffers[.console] = ""
    }
    
    func warning(_ w: String) {
        append(to: .debugger, "warning: \(w)\n")
    }
    
    func flush() {}
}

extension ConsoleViewController: ConsoleDelegate {
    func readLine() throws -> String {
        var inputBuffer: String? = nil
        DispatchQueue.main.async {
            self.consoleTextView.readLine {
                inputBuffer = $0
            }
        }
        
        // Capture the reference to the current task
        let task = execTask!
        while inputBuffer == nil {
            Thread.sleep(forTimeInterval: 0.001)
            if task.isCancelled {
                consoleTextView.reset()
                throw ExecutionError.cancelled
            }
        }
        defer {
            inputBuffer = nil
        }
        if let input = inputBuffer {
            self.println(KString(input))
            return input
        }
        throw ExecutionError.unexpected(nil)
    }
    
    func editableAfterIndex() -> Int {
        return (buffers[.console]?.count ?? 0) - 1
    }
}
