//
//  Executable.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/15/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Program {
    public var config: Configuration
    public var io: IOProtocol?
    var curStackSize: Int = 0
    
    public static var shared: Program = Program()
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        df.dateStyle = .medium
        return df
    }()

    /// Get the absolute time
    var currentTime: TimeInterval {
        return Date().timeIntervalSince1970
    }

    public init(config: Configuration = .init(), io: IOProtocol? = nil) {
        self.config = config
        self.io = io
    }
    
    /// Kelvin's recursion ability is very limited. This checks against stackoverflow that could terminate the application!
    /// - Throws: `ExecutionError.stackOverflow` if max stack size is exceeded.
    mutating func checkStackLimit() throws {
        if curStackSize > config.maxStackSize {
            throw ExecutionError.stackOverflow(config.maxStackSize)
        }
    }
    
    /// Compiles and runs the file at given path.
    /// - Parameter path: Path to source file.
    /// - Parameter config: Configuration object containing scope, retention policy, verbosity, etc.
    public func compileAndRun(fileAt path: String) throws {
        var content = ""
        io?.log("loading file at \(path)...")
        content = try FileSystem.shared.readFile(at: path)
        let t = Date().timeIntervalSince1970
        io?.log("compiling...")
        let statements = try Compiler.shared.compile(document: content)
        let millis = Int((Date().timeIntervalSince1970 - t) * 1000)
        io?.log("compilation successful in \(millis) milliseconds.")
        try run(statements)
    }
    
    /// Execute the given block on a thread that has stack size set to maximum.
    /// - Parameter block: The block to be performed
    @discardableResult
    public static func unlimitedStackExec<T>(_ block: @escaping () throws -> T) throws -> T {
        var result: T!
        var error: Error?
        
        // Execute the main program on a thread that does not have a stack limit!
        let thread = Thread() {
            do {
                result = try block()
            } catch let e {
                error = e
            }
        }
        
        // Remove the annoying stack limit!
        thread.stackSize = .max
        thread.start()
        
        while !thread.isFinished {
            Thread.sleep(forTimeInterval: 0.0001)
        }
        
        if let e = error { throw e }
        return result
    }

    /// Executes the program; all outputs are redirected to io specified by `Program.io`
    public func run(_ statements: [Statement], workItem: DispatchWorkItem? = nil) throws {
        // Record start time
        let startTime = currentTime
        
        // Save the current program execution scope.
        Scope.save()
        switch config.scope {
        case .useDefault:
            io?.log("restoring to default execution scope...")
            Scope.restoreDefault()
        default:
            break
        }
        
        io?.log("start time: \(dateFormatter.string(from: Date()))")
        io?.log("begin execution log:")
        
        // Main Kelvin program evaluation block
        let block: () throws -> Void = {
            for statement in statements {
                if let item = workItem, item.isCancelled {
                    throw ExecutionError.cancelled
                }
                do {
                    let result = try statement.node.simplify()
                    self.io?.log(Log(line: statement.line, input: statement.node, output: result))
                } catch let e as ExecutionError {
                    
                    // Add line number to throw stack
                    let w = ExecutionError.onLine(statement.line, err: e)
                    
                    // Stack overflow must be resolved here, where stack size is unrestricted.
                    if let root = ExecutionError.getRootCause(e) as? ExecutionError {
                        switch root {
                        case .stackOverflow:
                            throw ExecutionError.resolved(w.localizedDescription)
                        default:
                            break
                        }
                    }
                    throw w
                }
            }
        }
        
        // Execute the main program on a thread that does not have a stack limit!
        switch config.threadContext {
        case .maxStackSize:
            try Program.unlimitedStackExec(block)
        case .default:
            try block()
        }

        io?.log("end execution log.")
        io?.log("program terminated in \(Int((currentTime - startTime) * 1000)) milliseconds.")

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
    
    /// Preserves current execution scope, compiles and imports file at path.
    /// - Parameter path: Path to the file to be imported.
    public static func `import`(fileAt path: String) throws {
        try Program(config: .init(scope: .useCurrent, retentionPolicy: .preserveAll), io: nil)
            .compileAndRun(fileAt: path)
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
        public var threadContext: ThreadContext
        public var retentionPolicy: RetentionPolicy
        public var maxStackSize = 100000
        
        public init(
            scope: Scope = .useCurrent,
            retentionPolicy: RetentionPolicy = .restore,
            threadContext: ThreadContext = .default
        ) {
            self.scope = scope
            self.retentionPolicy = retentionPolicy
            self.threadContext = threadContext
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
        
        public enum ThreadContext {
            case maxStackSize
            case `default`
        }
    }
}
