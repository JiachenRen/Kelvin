//
//  Error.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/7/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Errors that occur during the compilation phase such as any bad syntax or
/// an incorrect number of arguments supplied to reserved binary/unary operations
public enum CompilerError: Error {
    case illegalArgument(errMsg: String)
    case syntax(errMsg: String)
}

public enum ArithmeticError: Error {
    case overflow
}

class KelvinError: Leaf, NaN {
    var description: String {
        return errMsg
    }
    
    var errMsg: String
    
    init(msg: String) {
        self.errMsg = msg
    }
    
    func equals(_ node: Node) -> Bool {
        if let err = node as? KelvinError {
            return err.errMsg == errMsg
        }
        return false
    }
}
