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
    
    func readLine() -> String {
        return ""
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
    
    func flush() {
        
    }
    
}
