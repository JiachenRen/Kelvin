//
//  InputProtocol.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/1/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public protocol IOProtocol {
    func readLine() -> String
    func print(_ n: Node)
    func println(_ n: Node)
    func log(_ l: String)
    func log(_ l: Program.Log)
    func error(_ e: String)
    func warning(_ w: String)
    func clear()
    func flush()
}
