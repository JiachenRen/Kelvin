//
//  NaN.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/7/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol NaN {}

extension NaN {

    /// Returns NaN because non-numerical classes such as variable
    /// conforms to this protocol.
    public var evaluated: Value? {
        return nil
    }

}
