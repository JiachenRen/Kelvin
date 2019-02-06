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
    
    private let tab = "      "
    
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
        if let line = l.line {
            let msg = "\(tab)# \(line)"
            Swift.print(colored ? msg.white : msg)
        }
        let output = "\(colored ? l.output.ansiColored : l.output.stringified)"
        Swift.print("\(tab)→ \(colored ? l.input.ansiColored : l.input.stringified)\n\(tab)= \(output)\n")
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
        Swift.print(output)
    }
    
    /// Main program execution interactive loop
    public func interactiveLoop() throws {
        
        Swift.print("Kelvin Algebra System. Copyright (c) 2019, Jiachen Ren.")
        
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
        
        while true {
            do {
                let open = openBrackets.reduce(0) {$0 + $1.value}
                if open == 0 {
                    Swift.print("\(tab)← ", terminator: "")
                } else {
                    Swift.print("\(tab)  ", terminator: "")
                }
                
                var input = Swift.readLine()?.trimmed ?? ""
                
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
