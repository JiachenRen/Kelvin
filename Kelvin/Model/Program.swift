//
//  Executable.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/15/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Program {
    
    /// The output of the program consisting of logs and outputs.
    public typealias Output = (logs: [Log], outputs: [Node])
    
    /// Results from executing statements are stored here.
    var logs = [Log]()
    
    /// Program outputs are stored here.
    var outputs = [Node]()
    
    var statements: [Node]
    
    init(_ statements: [Node]) {
        self.statements = statements
    }
    
    /// Execute the program and produce an output.
    /// - Parameter verbose: Whether to use verbose mode
    /// - Returns: A tuple consisting of program execution log and cumulative output.
    @discardableResult
    public func run(verbose: Bool = false) -> Output {
        
        // Clear logs and outputs before program execution.
        logs = [Log]()
        outputs = [Node]()
        
        if verbose {
            print("starting...\n\nprogram execution log: ")
        }
        
        statements.forEach {
            // Execute the statement and add it to logs
            let result = $0.simplify()
            
            // Create log
            let log = Log(input: $0, output: result)
            logs.append(log)
            
            if verbose {
                print(log, terminator: "\n\n")
            }
            
            // Generate outputs
            result.forEach {
                if let f = $0 as? Function {
                    switch f.name {
                    case "print":
                        f.args.elements.forEach {
                            outputs.append($0)
                        }
                    case "println":
                        f.args.elements.forEach {
                            outputs.append($0)
                            outputs.append("\n")
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        if verbose {
            print("program terminated.\n")
            print("cumulative output:")
            print(outputs.map {$0.stringified}.reduce("") {$0 + $1}, terminator: "\n")
        }
        
        // Clear all temporary variables, functions, and syntax definitions.
        Operation.restoreDefault()
        Variable.clearDefinitions()
        
        return (logs, outputs)
    }
    
    public struct Log: CustomStringConvertible {
        let input: Node
        let output: Node
        
        public var description: String {
            return "\t>>>\t\(input)\n\t\t\(output)"
        }
    }
}
