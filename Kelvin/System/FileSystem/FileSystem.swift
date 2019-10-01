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
    /// - Parameter isDirectory: Wether the path should represent a directory. Defaults to nil; only checks type of path if this value is provided.
    /// - Returns: An absolute URL that the path represents.
    private func resolve(_ path: String, asDirectory: Bool? = nil) throws -> URL {
        let path = patch(path)
        var url = URL(fileURLWithPath: path)
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        guard exists else {
            throw ExecutionError.general(errMsg: "the path \(path) does not exist.")
        }
        if let asDir = asDirectory, isDirectory.boolValue != asDir {
            let expected = asDir ? "directory" : "file"
            let found = isDirectory.boolValue ? "directory" : "file"
            let msg = "expected a \(expected), but the path \(path) represents a \(found)"
            throw ExecutionError.general(errMsg: msg)
        }
        // Remove '..' and '.'
        url.standardize()
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
    
    /// Converts path to either absolute or relative
    private func patch(_ path: String) -> String {
        return isRelative(path: path) ? convertToAbsolute(path) : path
    }
    
    /// Reads file at given path.
    /// - Parameter path: Path to the file, either absolute or relative
    /// - Returns: Contents of the file.
    public func readFile(at path: String) throws -> String {
        #if os(OSX)
        let url = try resolve(path, asDirectory: false)
        return try String(contentsOf: url)
        #else
        throw ExecutionError.unsupportedPlatform("OSX")
        #endif
    }
    
    /// - Returns: List of paths under given directory
    public func list(_ path: String) throws -> [String] {
        #if os(OSX)
        let url = try resolve(path, asDirectory: true)
        if #available(OSX 10.15, *) {
            return try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: .producesRelativePathURLs
            ).map {$0.relativePath}
        }
        return try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil
            )
            .map {$0.path}
        #else
        throw ExecutionError.unsupportedPlatform("OSX")
        #endif
    }
    
    /// - Returns: List of all paths under current working directory.
    public func list() throws -> [String] {
        return try list(workingDirectoryPath)
    }
    
    /// Checks if the given directory is a file/directory.
    /// - Parameter path: Path to file or directory.
    /// - Parameter asDirectory: Whether to assert path as file or directory
    public func assert(_ path: String, asDirectory: Bool) -> Bool {
        #if os(OSX)
        return (try? resolve(path, asDirectory: asDirectory)) != nil
        #else
        throw ExecutionError.unsupportedPlatform("OSX")
        #endif
    }
    
    /// Checks if the provided path exists.
    public func exists(_ path: String) -> Bool {
        return (try? resolve(path)) == nil ? false : true
    }
    
    /// Removes file or directory at path.
    /// If the path specified is a directory, the contents of the directory is removed recursively.
    public func remove(at path: String) throws {
        #if os(OSX)
        do {
            try FileManager.default.removeItem(at: try resolve(path))
        } catch let e as NSError {
            throw ExecutionError.general(errMsg: e.localizedDescription)
        }
        #else
        throw ExecutionError.unsupportedPlatform("OSX")
        #endif
    }
    
    /// Creates dir/file at path.
    public func createFile(at path: String) throws {
        #if os(OSX)
        let path = patch(path)
        if !FileManager.default.createFile(atPath: path, contents: nil) {
            throw ExecutionError.general(errMsg: "failed to create file at \(path)")
        }
        #else
        throw ExecutionError.unsupportedPlatform("OSX")
        #endif
    }
    
    /// Creates directory at path.
    /// If the path contains multiple non-existent directories, all the intermediate directoreis are also created.
    public func createDirectory(at path: String) throws {
        #if os(OSX)
        let path = patch(path)
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        } catch let e as NSError {
            throw ExecutionError.general(errMsg: e.localizedDescription)
        }
        #else
        throw ExecutionError.unsupportedPlatform("OSX")
        #endif
    }
    
    /// Writes to file at path. (File will be overwritten if already exists).
    /// If file does not exist, an error is thrown.
    /// - Parameter path: Path to the file, either absolute or relative
    /// - Parameter content: Content to write to the file
    /// - Parameter append: Append to file if true
    public func write(_ content: String, to path: String, append: Bool = false) throws {
        #if os(OSX)
        let url = try resolve(path, asDirectory: false)
        if append {
            guard #available(OSX 10.15, *) else {
                throw ExecutionError.general(errMsg: "append to end of file only available in OSX 10.15 or higher")
            }
            let file = try FileHandle(forUpdating: url)
            file.seekToEndOfFile()
            if let data = content.data(using: .utf8) {
                file.write(data)
            } else {
                throw ExecutionError.general(errMsg: "failed to encode string data")
            }
            file.closeFile()
        } else {
            try content.write(to: url, atomically: true, encoding: .utf8)
        }
        #else
        throw ExecutionError.unsupportedPlatform("OSX")
        #endif
    }
}
