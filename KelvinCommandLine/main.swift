//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

print("Kelvin Algebra System. Copyright (c) 2018, Jiachen Ren.")
print("\t: ", terminator: "")
while let expr = readLine() {
    do {
        let parent = try Compiler.compile(expr)
        print("\t: \(parent)")
        print("\t: \(parent.numericVal ?? .nan)")
        print("\t: \(parent.simplify())")
    } catch let err {
        print(err)
    }
    print("\t: ", terminator: "")
}

