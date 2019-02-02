//
//  Console.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

class Console: IOProtocol {
    private var output = ""
    
    func clear() {
        output = ""
    }
    
    func log(_ l: String) {
        Swift.print(">>> \(l)")
    }
    
    func log(_ l: Program.Log) {
        let output = "\(l.output.ansiColored)"
        Swift.print("\t>>>\t\(l.input.ansiColored)\n\t\t\(output)\n")
    }
    
    func error(_ e: String) {
        Swift.print(">>> \(e.red)")
    }
    
    func readLine() -> String {
        return Swift.readLine() ?? ""
    }
    
    private func format(_ n: Node) -> String {
        if let ks = n as? KString {
            return ks.string
        }
        return n.ansiColored
    }
    
    func print(_ n: Node) {
        output += format(n)
    }
    
    func println(_ n: Node) {
        output += format(n) + "\n"
    }
    
    func flush() {
        if output == "" {
            return
        }
        log("program output:")
        Swift.print(output, terminator: "")
    }
}
