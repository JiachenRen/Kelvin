//
//  Operator.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Operator: CustomStringConvertible {

    /// The padding for the operator when printing.
    public enum Padding {

        /// A space is added to the left
        case leftSide

        /// A space is added to the right
        case rightSide

        /// No space added
        case none

        /// The operator is padded with space on both sides.
        case bothSides
    }

    /// The name of the operator, e.g. `+`, `-`.
    public let name: String
    public let padding: Padding
    public let isPreferred: Bool

    /// Instantiates a new `Operator`.
    /// - Parameter name: Name of the operator, e.g. `+`
    /// - Parameter padding: Padding for the operator. Defaults to `.bothSides`
    public init(_ name: String, padding: Padding = .bothSides, isPreferred: Bool = true) {
        self.name = name
        self.padding = padding
        self.isPreferred = isPreferred
    }

    public var description: String {
        switch padding {
        case .bothSides:
            return " \(name) "
        case .leftSide:
            return " \(name)"
        case .rightSide:
            return "\(name) "
        case .none:
            return "\(name)"
        }
    }
}
