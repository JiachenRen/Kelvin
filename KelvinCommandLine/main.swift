//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

print("Kelvin Algebra System. Copyright (c) 2019, Jiachen Ren.")

// Base URL to /Examples directory
let baseURL = URL(fileURLWithPath: "/Users/jiachenren/Library/Mobile Documents/com~apple~CloudDocs/Documents/Developer/Kelvin/Kelvin/Model/Examples/")


/// Compile and run the file w/ the given file name under /Examples directory
fileprivate func compileAndRun(_ fileName: String) throws {
    do {
        var content = ""
        do {
            print("loading contents of absolute URL...")
            content = try String(contentsOf: URL(fileURLWithPath: fileName))
        } catch let e {
            print("\(e);\ntrying relative URL to examples...")
            
            do {
                content = try String(contentsOf: URL(fileURLWithPath: fileName, relativeTo: baseURL))
            } catch let r {
                print("\(r);\nfile not found - abort.")
                return
            }
        }
        let program = try Compiler.compile(document: content)
        program.run(verbose: true)
    } catch CompilerError.error(let line, let err) {
        print("error on line \(line): \(err)")
    }
}

// Main program execution loop
while true {
    do {
        print("    >>> ", terminator: "")
        let input = readLine() ?? ""
        
        // The run keyword tells the program to compile and run a file.
        // "run Misc", for example, runs /Examples/Misc.
        if let r = input.range(of: "run") {
            let fileName = String(input[input.index(after: r.upperBound)...])
            try compileAndRun(fileName)
            continue
        }
        
        // Compile and execute the input statement
        let parent = try Compiler.compile(input)
        print("      # \(parent)")
        print("      = \(parent.simplify())", terminator: "\n\n")
    } catch CompilerError.illegalArgument(let msg) {
        print("ERR >>> illegal argument: \(msg)")
    } catch CompilerError.syntax(let msg) {
        print("ERR >>> syntax: \(msg)")
    }
}
