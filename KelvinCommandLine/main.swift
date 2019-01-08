//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

print("Kelvin Algebra System. Copyright (c) 2018, Jiachen Ren.")
while true {
    do {
        print("INPUT: ", terminator: "")
        let input = readLine() ?? ""
        let parent = try Compiler.compile(input)
        print("     ~ \(parent.numericalVal ?? .nan)")
        print("     = \(parent.simplify())")
        print("     + \(parent.toAdditionOnlyForm())")
        print("     f \(parent.toAdditionOnlyForm().flatten())")
    } catch let err {
        print(err)
    }
}

