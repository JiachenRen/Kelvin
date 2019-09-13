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
    private let tab = "  "
    
    /// If verbose is false, all log messages are not printed.
    public var verbose: Bool
    
    init(verbose: Bool = false) {
        self.verbose = verbose
    }
    
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
            let msg = "\(tab)# \(line)"
            Swift.print(msg.white)
        }
        let output = "\(format(l.output))"
        let input = "\(format(l.input))"
        Swift.print("\(tab)→ \(input)\n\(tab)= \(output)\n")
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
        if let ks = n as? KString {
            return ks.string
        }
        return n.ansiColored
    }
    
    /// Append node `n` to output buffer
    public func print(_ n: Node) {
        output += format(n)
    }
    
    /// Append node `n` and a linebreak to output buffer
    public func println(_ n: Node) {
        output += format(n) + "\n"
    }
    
    /// Flush output buffer, which prints all pending messages to terminal.
    public func flush() {
        if output == "" {
            return
        }
        Swift.print(output)
    }
    
    /// Evaluates the expression represented by `expr`
    func eval(_ expr: String) {
        do {
            let output = try Compiler.compile(expr).simplify()
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
            try Program.compileAndRun(filePath)
            flush()
        } catch let e as KelvinError {
            error(e.localizedDescription)
            exit(EXIT_FAILURE)
        }
    }
    
    /// Kelvin REPL(Read-Evaluate-Print-Loop)
    public func repl() throws {
        Swift.print("Kelvin Algebra System REPL. Copyright (c) 2019, Jiachen Ren.")
        var openBrackets = [Compiler.Bracket: Int]()
        var buff: String? = nil
        
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
                let prompt = open == 0 ? "\(tab)← " : padding
                var input = readln(prompt: prompt)?.trimmingCharacters(in: .whitespaces) ?? ""
                
                let curOpenBrackets = Compiler.countOpenBrackets(input)
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
                    let _ = try Compiler.compile(input)
                }
                
                // Compile and execute the input statement
                clear()
                let parent = try Compiler.compile(input)
                let result = try parent.simplify()
                flush()
                log(Program.Log(line: nil, input: parent, output: result))
            } catch let e as KelvinError {
                resetCounters()
                error(e.localizedDescription)
            }
        }
    }
    
    public static func printUsage() {
        Swift.print("Usage: kelvin -i (enter interactive mode)")
        Swift.print("   or  kelvin -e <expr> (evaluate the expression that follows)")
        Swift.print("   or  kelvin -f [options] <filepath> (execute file at path)\n")
        Swift.print(" where options include:", terminator: "\n\n")
        Swift.print("    -v verbose")
    }
    
    /// An enum representation of available program arguments.
    public enum Argument: String {
        case expression = "e"
        case file = "f"
        case verbose = "v"
        case interactive = "i"
        
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


