//
//  Executable.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/15/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

// Replace with base URL to /Examples directory
fileprivate let baseURL = URL(fileURLWithPath: "/Users/jiachenren/Library/Mobile Documents/com~apple~CloudDocs/Documents/Developer/Kelvin/Examples/")

public class Program {

    /// The output of the program consisting of logs and outputs.
    public typealias Output = (logs: [Log], outputs: [Node])

    /// Results from executing statements are stored here.
    var logs = [Log]()

    /// Program outputs are stored here.
    var outputs = [Node]()

    var statements: [Node]
    
    var config: Configuration

    /// Get the absolute time
    var currentTime: TimeInterval {
        return Date().timeIntervalSince1970
    }

    init(_ statements: [Node], config: Configuration = Configuration.default) {
        self.statements = statements
        self.config = config
    }
    
    private func vPrint(_ s: Any) {
        if config.verbose {
            print(s)
        }
    }
    
    private func vPrint(_ s: Any, terminator t: String) {
        if config.verbose {
            print(s, terminator: t)
        }
    }
    
    /// Compile and run the file w/ the given file name under /Examples directory
    @discardableResult
    public static func compileAndRun(_ fileName: String, with config: Configuration?) throws -> Output {
        var content = ""
        do {
            print(">>> trying relative URL to examples...")
            let url = URL(fileURLWithPath: fileName, relativeTo: baseURL)
            content = try String(contentsOf: url)
            print(">>> loading contents of \(fileName)")
        } catch let e {
            print(">>> \(e);\n>>> resolving absolute URL...")
            do {
                content = try String(contentsOf: URL(fileURLWithPath: fileName))
                print(">>> loading contents of \(fileName)")
            } catch {
                throw ExecutionError.general(errMsg: "file not found - abort.")
            }
        }
        let t = Date().timeIntervalSince1970
        print(">>> compiling...")
        let program = try Compiler.compile(document: content)
        print(">>> compilation successful in \(Date().timeIntervalSince1970 - t) seconds.")
        if let c = config {
            program.config = c
        }
        return try program.run()
    }

    /// Execute the program and produce an output.
    /// - Parameter verbose: Whether to use verbose mode
    /// - Returns: A tuple consisting of program execution log and cumulative output.
    @discardableResult
    public func run() throws -> Output {

        // Clear logs and outputs before program execution.
        logs = [Log]()
        outputs = [Node]()

        /// Record start time
        let startTime = currentTime
        
        /// Save the current program execution scope.
        Scope.save()
        switch config.scope {
        case .useDefault:
            vPrint(">>> restoring to default execution scope...")
            Scope.restoreDefault()
        default:
            break
        }

        vPrint(">>> starting...\n>>> timestamp: \(startTime)\n>>> begin program execution log:\n")
    
        try statements.forEach {
            // Execute the statement and add it to logs
            let result = try $0.simplify()

            // Create log
            let log = Log(input: $0, output: result)
            logs.append(log)

            vPrint(log, terminator: "\n\n")

            // Generate outputs
            result.forEach {
                if let f = $0 as? Function {
                    switch f.name {
                    case "print":
                        f.elements.forEach {
                            outputs.append($0)
                        }
                    case "println":
                        f.elements.forEach {
                            outputs.append($0)
                            outputs.append("\n")
                        }
                    default:
                        break
                    }
                }
            }
        }

        vPrint(">>> end program execution log.\n")
        vPrint(">>> program output:\n")
        vPrint(outputs.map {
            $0.stringified
        }.reduce("") {
            $0 + $1
        }, terminator: "\n")
        vPrint(">>> program terminated in \(currentTime - startTime) seconds.")

        // Clear all temporary variables, functions, and syntax definitions.
        switch config.retentionPolicy {
        case .restore:
            Scope.restore()
        case .restoreToDefault:
            Scope.restoreDefault()
        case .preserveAll:
            Scope.popLast()
        }

        return (logs, outputs)
    }

    public struct Log: CustomStringConvertible {
        let input: Node
        let output: Node

        public var description: String {
            return "\t>>>\t\(input)\n\t\t\(output)"
        }
    }
    
    public struct Configuration {
        var verbose: Bool
        var scope: Scope
        var retentionPolicy: RetentionPolicy
        
        static var `default` = Configuration(verbose: true, scope: .useCurrent, retentionPolicy: .restore)
        
        enum Scope {
            case useCurrent
            case useDefault
        }
        
        enum RetentionPolicy {
            case restore
            case restoreToDefault
            case preserveAll
        }
    }
}
