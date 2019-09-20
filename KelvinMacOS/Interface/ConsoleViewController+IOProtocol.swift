//
//  ConsoleViewController+IOProtocol.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/8/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import Kelvin

extension ConsoleViewController: IOProtocol {
    
    private func format(_ n: Node) -> String {
        if let ks = n as? KString {
            return ks.string
        }
        return n.stringified
    }
    
    private func append(_ content: String) {
        consoleOutputBuffer += content
    }
    
    func print(_ n: Node) {
        append(format(n))
    }
    
    func println(_ n: Node) {
        append(format(n) + "\n")
    }
    
    func log(_ l: String) {
        Swift.print(l)
    }
    
    func log(_ l: Program.Log) {
        executionLogs.append(l)
    }
    
    func error(_ e: String) {
        consoleOutputBuffer += e
    }
    
    func clear() {
        executionLogs = []
        consoleOutputBuffer = ""
    }
    
    func warning(_ w: String) {
        consoleOutputBuffer += w
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
        throw ExecutionError.unexpected
    }
    
    func editableAfterIndex() -> Int {
        return consoleOutputBuffer.count - 1
    }
}
