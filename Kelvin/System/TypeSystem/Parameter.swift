//
//  Parameter.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import BigInt

/// `Parameter` is used to represent specify parameter type requirement. By giving a function a name,
/// the number of arguments, and the types of arguments, we can generate a unique signature that is used later to find definitions.
public struct Parameter: Equatable, CustomStringConvertible {
    private(set) var scope: Int
    private(set) var kType: KType
    private(set) var multiplicity: Multiplicity
    
    public var description: String {
        var postfix = ""
        switch multiplicity {
        case .count(let c):
            postfix = "(\(c))"
        case .any:
            postfix = "s"
        default:
            break
        }
        return kType.description + postfix
    }
    
    enum Multiplicity: Equatable {
        case unary
        case count(_ c: Int)
        case any
    }
    
    init(_ kType: KType, multiplicity: Multiplicity = .unary) {
        self.kType = kType
        self.scope = Parameter.calcScope(kType, multiplicity)
        self.multiplicity = multiplicity
    }
    
    init<T>(_ type: T.Type) {
        let kType = KType.resolve(type)
        guard kType != .unknown else {
            fatalError("cannot resolve type of \(String(describing: type)) as KType")
        }
        self.init(kType)
    }
    
    private static func calcScope(_ type: KType, _ mult: Multiplicity) -> Int {
        var mScore = 0
        switch mult {
        case .unary:
            mScore = 1
        case .count(let c):
            mScore = c
        case .any:
            mScore = 100000
        }
        var tScore = 0
        switch type {
        case .integer, .iterable:
            tScore = 10
        case .exact, .listProtocol:
            tScore = 100
        case .naN, .number:
            tScore = 1000
        case .node:
            tScore = 10000
        default:
            tScore = 1
        }
        return mScore * tScore
    }
    
    public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
        return lhs.kType == rhs.kType && lhs.multiplicity == rhs.multiplicity
    }
    
    static let string: Parameter = .init(.string)
    static let kSet: Parameter = .init(.kSet)
    static let float80: Parameter = .init(.float80)
    static let int: Parameter = .init(.int)
    static let bigInt: Parameter = .init(.bigInt)
    static let fraction: Parameter = .init(.fraction)
    static let exact: Parameter = .init(.exact)
    static let variable: Parameter = .init(.variable)
    static let constant: Parameter = .init(.constant)
    static let vector: Parameter = .init(.vector)
    static let matrix: Parameter = .init(.matrix)
    static let equation: Parameter = .init(.equation)
    static let pair: Parameter = .init(.pair)
    static let function: Parameter = .init(.function)
    static let bool: Parameter = .init(.bool)
    static let kType: Parameter = .init(.kType)
    static let closure: Parameter = .init(.closure)
    static let statements: Parameter = .init(.statements)
    static let integer: Parameter = .init(.integer)
    static let iterable: Parameter = .init(.iterable)
    static let number: Parameter = .init(.number)
    static let listProtocol: Parameter = .init(.listProtocol)
    static let node: Parameter = .init(.node)
    static let nan: Parameter = .init(.naN)
}
