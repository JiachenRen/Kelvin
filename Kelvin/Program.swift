//
//  Executable.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/15/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Program {

    public var statements: [Statement]
    
    public var config: Configuration
    
    public static var io: IOProtocol?

    /// Get the absolute time
    var currentTime: TimeInterval {
        return Date().timeIntervalSince1970
    }

    public init(_ statements: [Statement], config: Configuration = Configuration.default) {
        self.statements = statements
        self.config = config
    }
    
    /// Compile and run the file w/ the given file name under /Examples directory
    public static func compileAndRun(_ filePath: String, with config: Configuration? = nil) throws {
        var content = ""
        do {
            io?.log("trying relative URL to current working directory...")
            #if os(OSX)
                let url = URL(fileURLWithPath: Process().currentDirectoryPath)
                    .appendingPathComponent(filePath)
                content = try String(contentsOf: url)
                io?.log("loading contents of \(filePath)")
            #else
                let errMsg = "unable to resolve current directory - unsupported"
                throw ExecutionError.general(errMsg: errMsg)
            #endif
        } catch let e {
            io?.log("\(e.localizedDescription)")
            io?.log("resolving absolute URL...")
            do {
                content = try String(contentsOf: URL(fileURLWithPath: filePath))
                io?.log("loading contents of \(filePath)")
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

    /// Executes the program; all outputs are redirected to io specified by `Program.io`
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
                throw ExecutionError.onLine($0.line, err: e)
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
        public let line: Int?
        public let input: Node
        public let output: Node
        
        public init(line: Int? = nil, input: Node, output: Node) {
            self.line = line
            self.input = input
            self.output = output
        }
    }
    
    public struct Configuration {
        public var scope: Scope
        public var retentionPolicy: RetentionPolicy
        
        public static var `default` = Configuration(scope: .useCurrent, retentionPolicy: .restore)
        
        public init(scope: Scope, retentionPolicy: RetentionPolicy) {
            self.scope = scope
            self.retentionPolicy = retentionPolicy
        }
        
        public enum Scope {
            case useCurrent
            case useDefault
        }
        
        public enum RetentionPolicy {
            case restore
            case restoreToDefault
            case preserveAll
        }
    }
}
