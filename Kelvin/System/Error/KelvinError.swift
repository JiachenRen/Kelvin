//
//  KelvinError.swift
//  Kelvin
//
//  Created by Jiachen Ren on 10/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// All errors in Kelvin conforms to `KelvinError` protocol.
public protocol KelvinError: Error {
    var localizedDescription: String { get }
}
