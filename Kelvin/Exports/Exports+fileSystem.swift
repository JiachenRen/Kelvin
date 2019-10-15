//
//  Exports+fileSystem.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension Exports {
    static let fileSystem = FileSystem.exports
}

extension FileSystem {
    static let exports: [Operation] = [
        .unary(.readFile, String.self) {
            return try String(shared.readFile(at: $0))
        },
        .binary(.appendToFile, String.self, String.self) {
            try shared.write($1, to: $0, append: true)
            return KVoid()
        },
        .binary(.writeToFile, String.self, String.self) {
            try shared.write($1, to: $0, append: false)
            return KVoid()
        },
        .noArg(.getWorkingDirectory) {
            #if os(OSX)
            return String(shared.workingDirectoryPath)
            #else
            throw ExecutionError.general(errMsg: "unable to resolve working directory - unsupported platform")
            #endif
        },
        .unary(.setWorkingDirectory, String.self) {
            try shared.setWorkingDirectory($0)
            return KVoid()
        },
        .unary(.pathExists, String.self) {
            return shared.exists($0)
        },
        .unary(.isDirectory, String.self) {
            return shared.assert($0, asDirectory: true)
        },
        .unary(.removePath, String.self) {
            try shared.remove(at: $0)
            return KVoid()
        },
        .unary(.createFile, String.self) {
            try shared.createFile(at: $0)
            return KVoid()
        },
        .unary(.createDirectory, String.self) {
            try shared.createDirectory(at: $0)
            return KVoid()
        },
        .noArg(.listPaths) {
            return try List(shared.list())
        },
        .unary(.listPaths, String.self) {
            return try List(shared.list($0))
        },
    ]
}
