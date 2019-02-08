//
//  Executable.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/15/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Program {

    var statements: [Statement]
    
    var config: Configuration
    
    public static var io: IOProtocol?

    /// Get the absolute time
    var currentTime: TimeInterval {
        return Date().timeIntervalSince1970
    }

    init(_ statements: [Statement], config: Configuration = Configuration.default) {
        self.statements = statements
        self.config = config
    }
    
    /// Compile and run the file w/ the given file name under /Examples directory
    public static func compileAndRun(_ fileName: String, with config: Configuration? = nil) throws {
        var content = ""
        do {
            io?.log("trying relative URL to current working directory...")
            let url = URL(fileURLWithPath: Process().currentDirectoryPath)
                .appendingPathComponent(fileName)
            content = try String(contentsOf: url)
            io?.log("loading contents of \(fileName)")
        } catch let e {
            io?.log("\(e.localizedDescription)")
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
        var program = try Compiler.compile(document: content)
        io?.log("compilation successful in \(Date().timeIntervalSince1970 - t) seconds.")
        if let c = config {
            program.config = c
        }
        try program.run()
    }

    /// Execute the program and produce an output.
    /// - Returns: A tuple consisting of program execution log and cumulative output.
    public func run(workItem: DispatchWorkItem? = nil) throws {

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
        Program.io?.log("begin program execution log:")
    
        try statements.forEach {
            if let item = workItem, item.isCancelled {
                throw ExecutionError.cancelled
            }
            
            do {
                // Execute the statement and add it to logs
                let result = try $0.node.simplify()
                
                // Create log
                let log = Log(line: $0.line, input: $0.node, output: result)
                Program.io?.log(log)
            } catch let e as KelvinError {
                throw ExecutionError.on(line: $0.line, err: e)
            }
        }

        Program.io?.log("end program execution log.")
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
    
    public struct Statement {
        let line: Int
        let node: Node
    }

    public struct Log {
        let line: Int?
        let input: Node
        let output: Node
    }
    
    public struct Configuration {
        var scope: Scope
        var retentionPolicy: RetentionPolicy
        
        static var `default` = Configuration(scope: .useCurrent, retentionPolicy: .restore)
        
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
