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

    /// Get the absolute time
    var currentTime: TimeInterval {
        return Date().timeIntervalSince1970
    }

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

        /// Record start time
        let startTime = currentTime

        if verbose {
            print(">>> starting...\n>>> timestamp: \(startTime)\n>>> begin execution log:\n")
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
            print(">>> end execution log.\n")
            print(">>> program output:\n")
            print(outputs.map {
                $0.stringified
            }.reduce("") {
                $0 + $1
            }, terminator: "\n")
            print(">>> program terminated in \(currentTime - startTime) seconds.")
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
