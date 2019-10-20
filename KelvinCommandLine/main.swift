//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation
import Kelvin

let args = CommandLine.arguments

// Set up console
let console = Console(verbose: true)

// Use unretricted stack size
Program.shared.config.maxStackSize = .max

// Link program output to console
Program.shared.io = console

// Parse program arguments and decide what to do
// No arguments passed, enter REPL interactive mode
if args.count == 1 {
    try console.repl()
    exit(EXIT_SUCCESS)
}
switch try Console.Argument.parse(args[1]) {
case .expression where args.count == 3:
    // Evaluate expression
    let expr = args[2]
    console.eval(expr)
case .file where args.count == 3:
    // Execute file at path (verbose = false)
    console.verbose = false
    try console.compileAndRun(args[2])
case .file where args.count == 4:
    let config = try Console.Argument.parse(args[2])
    switch config {
    case .debug:
        // Turn on stack trace for debug mode
        StackTrace.shared.isEnabled = true
        StackTrace.shared.debugOn = true
    default:
        break
    }
    // Execute file at path (verbose = true)
    console.verbose = config == .verbose
    try console.compileAndRun(args[3])
default:
    print("Error: Invalid arguments.")
    Console.printUsage()
    exit(EXIT_FAILURE)
}

exit(EXIT_SUCCESS)
