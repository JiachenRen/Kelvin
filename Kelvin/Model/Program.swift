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

    var statements: [Node]
    
    var config: Configuration
    
    public static var io: IOProtocol?

    /// Get the absolute time
    var currentTime: TimeInterval {
        return Date().timeIntervalSince1970
    }

    init(_ statements: [Node], config: Configuration = Configuration.default) {
        self.statements = statements
        self.config = config
    }
    
    /// Compile and run the file w/ the given file name under /Examples directory
    public static func compileAndRun(_ fileName: String, with config: Configuration?) throws {
        var content = ""
        do {
            io?.log("trying relative URL to examples...")
            let url = URL(fileURLWithPath: fileName, relativeTo: baseURL)
            content = try String(contentsOf: url)
            io?.log("loading contents of \(fileName)")
        } catch let e {
            io?.error("\(e.localizedDescription)")
            io?.log("resolving absolute URL...")
            do {
                content = try String(contentsOf: URL(fileURLWithPath: fileName))
                io?.log("loading contents of \(fileName)")
            } catch let e {
                throw ExecutionError.general(errMsg: e.localizedDescription)
            }
        }
        let t = Date().timeIntervalSince1970
        io?.log("compiling...")
        let program = try Compiler.compile(document: content)
        io?.log("compilation successful in \(Date().timeIntervalSince1970 - t) seconds.")
        if let c = config {
            program.config = c
        }
        try program.run()
    }

    /// Execute the program and produce an output.
    /// - Parameter verbose: Whether to use verbose mode
    /// - Returns: A tuple consisting of program execution log and cumulative output.
    public func run() throws {

        /// Record start time
        let startTime = currentTime
        
        /// Save the current program execution scope.
        Scope.save()
        switch config.scope {
        case .useDefault:
            Program.io?.log("restoring to default execution scope...")
            Scope.restoreDefault()
        default:
            break
        }

        Program.io?.log("starting...")
        Program.io?.log("timestamp: \(startTime)")
        Program.io?.log("begin program execution log:\n")
    
        try statements.forEach {
            // Execute the statement and add it to logs
            let result = try $0.simplify()

            // Create log
            let log = Log(input: $0, output: result)
            Program.io?.log(log)
        }

        Program.io?.log("end program execution log.\n")
        Program.io?.log("program terminated in \(currentTime - startTime) seconds.")

        // Clear all temporary variables, functions, and keyword definitions.
        switch config.retentionPolicy {
        case .restore:
            Scope.restore()
        case .restoreToDefault:
            Scope.restoreDefault()
        case .preserveAll:
            Scope.popLast()
        }
    }

    public struct Log {
        let input: Node
        let output: Node
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
