//
//  Transfer.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/3/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public enum Transfer: KelvinError {
    case `return`(_ node: Node?)
    case `throw`(_ node: Node?)
}

public enum Control: KelvinError {
    case `continue`
    case `break`
}
