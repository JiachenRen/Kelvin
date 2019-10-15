//
//  Constant.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/15/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public class Constant: Number {
    static let marker = "\\"
    public var stringified: String { "\(Constant.marker)\(name.rawValue)" }
    public var ansiColored: String { stringified.bold.magenta }
    public var float80: Float80 { val }
    
    public let name: Name
    public let val: Float80
    
    public enum Name: String {
        case e
        case pi
        case inf
    }
    
    public static let definitions: [Name: Float80] = [
        .e: Float80(exactly: M_E)!,
        .pi: Float80.pi,
        .inf: Float80.infinity,
    ]
    
    public init(_ name: Name) {
        self.name = name
        self.val = Constant.definitions[name]!
    }
    
    convenience init?(_ literal: String) {
        guard let name = Name(rawValue: literal) else {
            return nil
        }
        self.init(name)
    }
    
    public func simplify() -> Node {
        switch Mode.shared.rounding {
        case .approximate:
            return val
        default:
            return self
        }
    }
    
    public func equals(_ node: Node) -> Bool {
        guard let const = node as? Constant else {
            return false
        }
        return const.name == name
    }
}
