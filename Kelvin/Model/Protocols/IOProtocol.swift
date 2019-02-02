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
    func print(_ s: String)
    func log(_ l: String)
    func log(_ l: Program.Log)
    func error(_ e: String)
    func clear()
    func flush()
}

extension IOProtocol {
    public func println(_ s: String) {
        print(s + "\n")
    }
}
