//
//  Keyword.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/24/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

enum DataType: String, CustomStringConvertible {
    case string
    case list
    case number
    case variable
    case vector
    case matrix
    case equation
    case pair
    case function
    case bool
    
    var description: String {
        return rawValue
    }
    
    static func resolve(_ node: Node) throws -> DataType {
        if node is KString {
            return .string
        } else if node is List {
            return .list
        } else if node is NSNumber {
            return .number
        } else if node is Variable {
            return .variable
        } else if node is Vector {
            return .vector
        } else if node is Matrix {
            return .matrix
        } else if node is Equation {
            return .equation
        } else if node is Pair {
            return .pair
        } else if node is Function {
            return .function
        } else if node is Bool {
            return .bool
        }
        throw ExecutionError.general(errMsg: "unable to resolve type of \(node)")
    }
}
