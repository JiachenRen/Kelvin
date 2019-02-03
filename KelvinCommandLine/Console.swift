//
//  Console.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Console: IOProtocol {
    private var output = ""
    public var colored: Bool
    public var verbose: Bool
    
    init(colored: Bool = false, verbose: Bool = false) {
        self.colored = colored
        self.verbose = verbose
    }
    
    public func clear() {
        output = ""
    }
    
    public func log(_ l: String) {
        if !verbose {
            return
        }
        Swift.print("→ \(l)")
    }
    
    public func log(_ l: Program.Log) {
        if !verbose {
            return
        }
        let output = "\(colored ? l.output.ansiColored : l.output.stringified)"
        Swift.print("      → \(colored ? l.input.ansiColored : l.input.stringified)\n      = \(output)\n")
    }
    
    public func error(_ e: String) {
        Swift.print("→ \(colored ? e.red : e)", terminator: "\n\n")
    }
    
    public func readLine() -> String {
        return Swift.readLine() ?? ""
    }
    
    private func format(_ n: Node) -> String {
        if let ks = n as? KString {
            return ks.string
        }
        return colored ? n.ansiColored : n.stringified
    }
    
    public func print(_ n: Node) {
        output += format(n)
    }
    
    public func println(_ n: Node) {
        output += format(n) + "\n"
    }
    
    public func flush() {
        if output == "" {
            return
        }
        log("program output:")
        Swift.print(output, terminator: "\n\n")
    }
    
    /// Main program execution interactive loop
    public func interactiveLoop() throws {
        
        Swift.print("Kelvin Algebra System. Copyright (c) 2019, Jiachen Ren.")
        
        while true {
            do {
                Swift.print("      ← ", terminator: "")
                let input = Swift.readLine() ?? ""
                
                // Compile and execute the input statement
                clear()
                let parent = try Compiler.compile(input)
                let result = try parent.simplify()
                flush()
                log(Program.Log(line: nil, input: parent, output: result))
            } catch CompilerError.illegalArgument(let msg) {
                error("illegal argument: \(msg)")
            } catch CompilerError.syntax(let msg) {
                error("syntax: \(msg)")
            } catch CompilerError.error(onLine: let n, let err) {
                switch err {
                case .syntax(let msg):
                    error("syntax error on line \(n): \(msg)")
                case .illegalArgument(let msg):
                    error("illegal argument on line \(n): \(msg)")
                default:
                    error("unexpected error on line \(n): \(err)")
                }
            } catch ExecutionError.general(let msg) {
                error("\(msg)")
            }
        }
    }
    
    public static func printUsage() {
        Swift.print("Usage: kelvin -c")
        Swift.print("   or  kelvin -e <expr>")
        Swift.print("   or  kelvin -f [options] <filepath>\n")
        Swift.print("Type kelvin without an option to enter interactive mode.\n")
        Swift.print(" where options include:", terminator: "\n\n")
        Swift.print("    -c format outputs with ANSI")
        Swift.print("    -e <expr> evaluate the expression that follows")
        Swift.print("    -f <filepath> execute the content of the file")
        Swift.print("    -v verbose")
        Swift.print("    -vc verbose output with ANSI\n")
    }
}
