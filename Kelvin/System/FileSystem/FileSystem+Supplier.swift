//
//  Supplier.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

extension FileSystem: Supplier {
    static let exports: [Operation] = [
        .unary(.readFile, KString.self) {
            return try KString(shared.readFile(at: $0.string))
        },
        .binary(.appendToFile, KString.self, KString.self) {
            try shared.write($1.string, to: $0.string, append: true)
            return KVoid()
        },
        .binary(.writeToFile, KString.self, KString.self) {
            try shared.write($1.string, to: $0.string, append: false)
            return KVoid()
        },
        .noArg(.getWorkingDirectory) {
            #if os(OSX)
            return KString(shared.workingDirectoryPath)
            #else
            throw ExecutionError.general(errMsg: "unable to resolve working directory - unsupported platform")
            #endif
        },
        .unary(.setWorkingDirectory, KString.self) {
            try shared.setWorkingDirectory($0.string)
            return KVoid()
        },
        .unary(.pathExists, KString.self) {
            return shared.exists($0.string)
        },
        .unary(.isDirectory, KString.self) {
            return shared.assert($0.string, asDirectory: true)
        },
        .unary(.removePath, KString.self) {
            try shared.remove(at: $0.string)
            return KVoid()
        },
        .unary(.createFile, KString.self) {
            try shared.createFile(at: $0.string)
            return KVoid()
        },
        .unary(.createDirectory, KString.self) {
            try shared.createDirectory(at: $0.string)
            return KVoid()
        },
        .noArg(.listPaths) {
            return try List(shared.list().map {KString($0)})
        },
        .unary(.listPaths, KString.self) {
            return try List(shared.list($0.string).map {KString($0)})
        },
    ]
}
