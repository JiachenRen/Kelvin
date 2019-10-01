//
//  ExportProtocol.swift
//  Kelvin
//
//  Created by Jiachen Ren on 9/30/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

/// Classes that conform to the `Supplier` protocol exports/bridges relevant functions
/// to Kelvin operations registry. That is, linking interface with implementation.
protocol Supplier {
    static var exports: [Operation] { get }
}
