//
//  Typealiases.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/7/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public typealias Unary = (Node) -> Node
public typealias Binary = (Node, Node) -> Node
public typealias PUnary = (Node) -> Bool
public typealias PBinary = (Node, Node) -> Bool
public typealias NUnary = (Float80) -> Float80
public typealias NBinary = (Float80, Float80) -> Float80
public typealias Definition = ([Node]) throws -> Node?
