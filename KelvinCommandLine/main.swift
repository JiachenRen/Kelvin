//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

print("Kelvin Algebra System. Copyright (c) 2019, Jiachen Ren.")
Program.io = Console()

// Main program execution loop
while true {
    do {
        print("    >>> ", terminator: "")
        let input = readLine() ?? ""
        
        // Compile and execute the input statement
        Program.io?.clear()
        let parent = try Compiler.compile(input)
        print("      # \(parent.ansiColored)")
        print("      = \(try parent.simplify().ansiColored)", terminator: "\n\n")
        Program.io?.flush()
    } catch CompilerError.illegalArgument(let msg) {
        print("ERR >>> illegal argument: \(msg)", terminator: "\n\n")
    } catch CompilerError.syntax(let msg) {
        print("ERR >>> syntax: \(msg)", terminator: "\n\n")
    } catch CompilerError.error(onLine: let n, let err) {
        switch err {
        case .syntax(let msg):
            print("ERR >>> syntax error on line \(n): \(msg)", terminator: "\n\n")
        case .illegalArgument(let msg):
            print("ERR >>> illegal argument on line \(n): \(msg)", terminator: "\n\n")
        default:
            print("ERR >>> unexpected error on line \(n): \(err)", terminator: "\n\n")
        }
    } catch ExecutionError.general(let msg) {
        print("ERR >>> \(msg)", terminator: "\n\n")
    }
}
