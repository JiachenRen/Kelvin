//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

let args = CommandLine.arguments

// Set up console
let console = Console(colored: false, verbose: true)
Program.io = console

// No arguments, enter interactive mode.
if args.count == 1 {
    try console.interactiveLoop()
} else {
    switch try Option.resolve(args[1]) {
    case .expression where args.count == 3:
        let expr = args[2]
        let output = try Compiler.compile(expr).simplify()
        print(output.stringified)
    case .colored:
        console.colored = true
        try console.interactiveLoop()
    case .file where args.count == 3:
        console.colored = false
        console.verbose = false
        try Program.compileAndRun(args[2])
    case .file where args.count == 4:
        let config = try Option.resolve(args[2])
        console.colored = false
        switch config {
        case .verbose:
            console.verbose = true
        case .colored:
            console.colored = true
        case .verboseAndColored:
            console.verbose = true
            console.colored = true
        default:
            print("Unavailable option: \(config.rawValue)")
            Console.printUsage()
            exit(EXIT_FAILURE)
        }
        try Program.compileAndRun(args[3])
    default:
        print("Error: Invalid arguments.")
        Console.printUsage()
        exit(EXIT_FAILURE)
    }
}

exit(EXIT_SUCCESS)
