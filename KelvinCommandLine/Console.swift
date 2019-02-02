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
        let output = "\(l.output.stringified)".green
        Swift.print("\t>>>\t\(l.input.stringified)\n\t\t\(output)\n")
    }
    
    func error(_ e: String) {
        Swift.print(">>> \(e.red)")
    }
    
    func readLine() -> String {
        return Swift.readLine() ?? ""
    }
    
    func print(_ s: String) {
        output += s
    }
    
    func flush() {
        if output == "" {
            return
        }
        log("program output:")
        Swift.print(output, terminator: "")
    }
}
