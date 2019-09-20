//
//  FileSystem.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/12/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Kelvin language's built in file manager
public class FileSystem {
    
    /// Shared singleton instance of FileSystem
    public static var shared: FileSystem = {
        return FileSystem()
    }()
    
    /// Current working directory path, used for all relative URLs.
    private(set) var workingDirectoryPath: String
    
    /// Initializes a new FileSystem instance.
    init() {
        #if os(OSX)
        workingDirectoryPath = Process().currentDirectoryPath
        #else
        workingDirectoryPath = ""
        #endif
    }
    
    /// Create an absolute URL from relative/absolute path and checks if it exists.
    /// - Parameter path: Path to be converted to URL
    /// - Parameter isDirectory: Wether the path should represent a directory.
    /// - Returns: An absolute URL that the path represents.
    private func resolve(_ path: String, asDirectory: Bool) throws -> URL {
        let path = isRelative(path: path) ? convertToAbsolute(path) : path
        let url = URL(fileURLWithPath: path)
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        guard exists else {
            throw ExecutionError.general(errMsg: "the path \(path) does not exist.")
        }
        guard isDirectory.boolValue == asDirectory else {
            let expected = asDirectory ? "directory" : "file"
            let found = isDirectory.boolValue ? "directory" : "file"
            let msg = "expected a \(expected), but the path \(path) represents a \(found)"
            throw ExecutionError.general(errMsg: msg)
        }
        return url
    }
    
    /// Converts relative path to absolute path under current working directory.
    /// - Parameter path: A relative path
    private func convertToAbsolute(_ path: String) -> String {
        return URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent(path).path
    }
    
    /// Set current working directory of project.
    /// - Parameter path: Path to working directory.
    public func setWorkingDirectory(_ path: String) throws {
        workingDirectoryPath = try resolve(path, asDirectory: true).path
    }
    
    /// - Returns: True if the path is relative
    private func isRelative(path: String) -> Bool {
        return !path.starts(with: "/")
    }
    /// Reads file at given path.
    /// - Parameter path: Path to the file, either absolute or relative
    /// - Returns: Contents of the file.
    public func readFile(at path: String) throws -> String {
        #if os(OSX)
        let url = try resolve(path, asDirectory: false)
        return try String(contentsOf: url)
        #else
        let errMsg = "unable to resolve current directory - unsupported"
        throw ExecutionError.general(errMsg: errMsg)
        #endif
    }
}
