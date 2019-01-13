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
        print("    >>> ", terminator: "")
        let input = readLine() ?? ""
        let parent = try Compiler.compile(input)
//        print("     ~: \(parent.evaluated ?? Double.nan)")
//        print("     =: \(parent.simplify())")
//        print("- -> +: \(parent.toAdditionOnlyForm())")
//        print("/ -> *: \(parent.toExponentialForm())")
        print("      # \(parent)")
        print("      = \(parent.simplify())")
        print("      ~ \(parent.evaluated ?? Double.nan)")
        print()
    } catch CompilerError.illegalArgument(let msg) {
        print("ERR >>> illegal argument: \(msg)")
    } catch CompilerError.syntax(let msg) {
        print("ERR >>> syntax: \(msg)")
    }
}
