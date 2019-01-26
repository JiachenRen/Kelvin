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
    
    var description: String {
        return rawValue
    }
}
