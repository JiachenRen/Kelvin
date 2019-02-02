//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

print("Kelvin Algebra System. Copyright (c) 2019, Jiachen Ren.")
let console = Console(colored: false)
Program.io = console

// Main program execution loop
while true {
    do {
        print("      ← ", terminator: "")
        let input = readLine() ?? ""
        
        // Compile and execute the input statement
        console.clear()
        let parent = try Compiler.compile(input)
        console.log(Program.Log(input: parent, output: try parent.simplify()))
        console.flush()
    } catch CompilerError.illegalArgument(let msg) {
        console.error("illegal argument: \(msg)")
    } catch CompilerError.syntax(let msg) {
        console.error("syntax: \(msg)")
    } catch CompilerError.error(onLine: let n, let err) {
        switch err {
        case .syntax(let msg):
            console.error("syntax error on line \(n): \(msg)")
        case .illegalArgument(let msg):
            console.error("illegal argument on line \(n): \(msg)")
        default:
            console.error("unexpected error on line \(n): \(err)")
        }
    } catch ExecutionError.general(let msg) {
        console.error("\(msg)")
    }
}
