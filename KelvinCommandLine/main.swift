//
//  main.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 11/10/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Foundation

print("Kelvin Algebra System. Copyright (c) 2019, Jiachen Ren.")
//while true {
//    do {
//        print("    >>> ", terminator: "")
//        let input = readLine() ?? ""
//        let parent = try Compiler.compile(input)
////        print("     ~: \(parent.evaluated ?? Double.nan)")
////        print("     =: \(parent.simplify())")
////        print("- -> +: \(parent.toAdditionOnlyForm())")
////        print("/ -> *: \(parent.toExponentialForm())")
//        print("      # \(parent)")
//        print("      = \(parent.simplify())")
//        print("      ~ \(parent.evaluated ?? Double.nan)")
//        print()
//    } catch CompilerError.illegalArgument(let msg) {
//        print("ERR >>> illegal argument: \(msg)")
//    } catch CompilerError.syntax(let msg) {
//        print("ERR >>> syntax: \(msg)")
//    }
//}

let baseURL = URL(fileURLWithPath: "/Users/jiachenren/Library/Mobile Documents/com~apple~CloudDocs/Documents/Developer/Kelvin/Kelvin/Model/Examples/")
let content = try String(contentsOf: URL(fileURLWithPath: "Misc", relativeTo: baseURL))
do {
    let program = try Compiler.compile(document: content)
    program.run(verbose: true)
} catch CompilerError.error(let line, let err) {
    print("error on line \(line): \(err)")
}
