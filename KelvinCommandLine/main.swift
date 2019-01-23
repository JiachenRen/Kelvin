//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

print("Kelvin Algebra System. Copyright (c) 2019, Jiachen Ren.")

// Main program execution loop
while true {
    do {
        print("    >>> ", terminator: "")
        let input = readLine() ?? ""
        
        // Compile and execute the input statement
        let parent = try Compiler.compile(input)
        print("      # \(parent.stringified)")
        print("      = \(try parent.simplify().stringified)", terminator: "\n\n")
    } catch CompilerError.illegalArgument(let msg) {
        print("ERR >>> illegal argument: \(msg)", terminator: "\n\n")
    } catch CompilerError.syntax(let msg) {
        print("ERR >>> syntax: \(msg)", terminator: "\n\n")
    } catch ExecutionError.general(let msg) {
        print("ERR >>> \(msg)", terminator: "\n\n")
    }
}
