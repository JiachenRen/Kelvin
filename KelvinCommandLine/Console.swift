//
//  Console.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import Kelvin

public class Console: IOProtocol {
    private var output = ""
    private let tab = "  "
    
    /// If verbose is false, all log messages are not printed.
    public var verbose: Bool
    
    /// If output should be buffered. If this is set to false, any outputs are printed immediately.
    private var buffered = true
    
    /// Keep track of all the outputs from the console.
    /// The first element is the path to current working directory.
    private var out: [Node] = [] {
        didSet {
            Variable.define("out", List(out))
        }
    }
    
    init(verbose: Bool = false) {
        self.verbose = verbose
    }
    
    // MARK: - IO Protocol
    
    /// Clears the output buffer of the console
    public func clear() {
        output = ""
    }
    
    public func log(_ l: String) {
        if !verbose {
            return
        }
        Swift.print("→ \(l)".white)
    }
    
    public func log(_ l: Program.Log) {
        if !verbose {
            return
        }
        if let line = l.line {
            printLineNumber(line)
        }
        printInput(l.input)
        printOutput(l.output)
    }
    
    private func printInput(_ input: Node) {
        Swift.print("\(tab)→ \(format(input))")
    }
    
    private func printOutput(_ output: Node) {
        Swift.print("\(tab)= \(format(output))\n")
    }
    
    private func printLineNumber(_ line: Int) {
        Swift.print("\(tab)# \(line)".white)
    }
    
    /// Formats and prints `e` as an error (red).
    public func error(_ e: String) {
        Swift.print("→ \(e)".red, terminator: "\n\n")
    }
    
    /// Formats and prints `w` as a warning (yellow).
    public func warning(_ w: String) {
        Swift.print("→ \(w.yellow)".yellow, terminator: "\n\n")
    }
    
    /// Read a line from terminal.
    public func readLine() -> String {
        return readln() ?? ""
    }
    
    /// Reads from terminal, making use of libedit.tbd
    /// In this fashion, terminal history,
    /// - Parameter prompt: The prompt to be displayed
    func readln(prompt: String? = nil, addToHistory: Bool = true) -> String? {
        guard let cString = readline(prompt) else { return nil }
        defer { free(cString) }
        if addToHistory { add_history(cString) }
        return(String(cString: cString))
    }
    
    /// Converts node to its String representation.
    private func format(_ n: Node) -> String {
        if let ks = n as? String {
            return ks
        }
        return n.ansiColored
    }
    
    /// Append node `n` to output buffer
    public func print(_ n: Node) {
        let s = format(n)
        if buffered {
            output += s
        } else {
            Swift.print(s, terminator: "")
        }
    }
    
    /// Append node `n` and a linebreak to output buffer
    public func println(_ n: Node) {
        let s = format(n) + "\n"
        if buffered {
            output += s
        } else {
            Swift.print(s, terminator: "")
        }
    }
    
    /// Flush output buffer, which prints all pending messages to terminal.
    public func flush() {
        if output == "" {
            return
        }
        Swift.print(output)
    }
    
    // MARK: - REPL
    
    /// Evaluates the expression represented by `expr`
    func eval(_ expr: String) {
        do {
            let output = try Compiler.shared.compile(expr).simplify()
            Swift.print(output.stringified)
        } catch let e as KelvinError {
            error(e.localizedDescription)
        } catch let e {
            error("internal error: \(e.localizedDescription)")
        }
    }
    
    /// Compiles and executes Kelvin source file at path
    func compileAndRun(_ filePath: String) throws {
        do {
            try Program.shared.compileAndRun(fileAt: filePath)
            flush()
        } catch let e as KelvinError {
            error(e.localizedDescription)
            exit(EXIT_FAILURE)
        }
    }
    
    /// Kelvin REPL(Read-Evaluate-Print-Loop)
    public func repl() throws {
        Swift.print("Access history with out[line number]. Kelvin Algebra System REPL. Copyright (c) 2019, Jiachen Ren.\n")
        var openBrackets = [Compiler.Bracket: Int]()
        var buff: String? = nil
        
        // Add working directory path as first env var.
        out.append(String(Process().currentDirectoryPath))
        
        // Print any outputs to console immediately
        buffered = false
        
        func resetCounters() {
            openBrackets = [
                .curly: 0,
                .square: 0,
                .round: 0
            ]
            buff = nil
        }
        
        resetCounters()
        
        // REPL loop
        while true {
            do {
                let open = openBrackets.reduce(0) {$0 + $1.value}
                let padding = repeatElement("\(tab)", count: open + 1)
                    .reduce("  ") {$0 + $1}
                if open == 0 {
                    printLineNumber(out.count)
                }
                let prompt = open == 0 ? "\(tab)← " : padding
                var input = readln(prompt: prompt)?.trimmingCharacters(in: .whitespaces) ?? ""
                
                let curOpenBrackets = Compiler.shared.countOpenBrackets(input)
                openBrackets[.square]! += curOpenBrackets[.square]!
                openBrackets[.round]! += curOpenBrackets[.round]!
                openBrackets[.curly]! += curOpenBrackets[.curly]!
                
                if openBrackets.allSatisfy({$0.value == 0}) {
                    
                    // All brackets have been closed at this point.
                    if let b = buff {
                        input = b + input
                        buff = nil
                    }
                } else if openBrackets.allSatisfy({$0.value >= 0}) {
                    if buff == nil {
                        buff = ""
                    }
                    buff?.append(input)
                    
                    // Temporary fix
                    if input == "}" {
                        buff?.append(";")
                    }
                    continue
                } else {
                    let _ = try Compiler.shared.compile(input)
                }
                
                // Compile and execute the input statement
                let expr = try Compiler.shared.compile(input)
                printInput(expr)
                let result = try expr.simplify()
                printOutput(result)
                out.append(result)
                
            } catch let e as KelvinError {
                resetCounters()
                error(e.localizedDescription)
            }
        }
    }
    
    public static func printUsage() {
        Swift.print("Usage: kelvin (enter interactive mode)")
        Swift.print("   or  kelvin -e <expr> (evaluate the expression that follows)")
        Swift.print("   or  kelvin -f [options] <filepath> (execute file at path)\n")
        Swift.print(" where options include:", terminator: "\n\n")
        Swift.print("    -v verbose")
        Swift.print("    -d debug")
    }
    
    /// An enum representation of available program arguments.
    public enum Argument: String {
        case expression = "e"
        case file = "f"
        case verbose = "v"
        case debug = "d"
        
        /// Parses raw argument string to option
        public static func parse(_ raw: String) throws -> Argument {
            var raw = raw
            raw.removeFirst()
            
            guard let option = Argument(rawValue: raw) else {
                Swift.print("Unrecognized option: \(raw)")
                Console.printUsage()
                exit(EXIT_FAILURE)
            }
            
            return option
        }
    }
}


