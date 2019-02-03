//
//  KelvinTests.swift
//  KelvinTests
//
//  Created by Jiachen Ren on 11/4/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import XCTest
@testable import Kelvin

class KelvinTests: XCTestCase {

    override func setUp() {
        Program.io = Console(colored: false, verbose: true)
        restoreDefault()
    }

    override func tearDown() {
        restoreDefault()
        Program.io?.flush()
    }
    
    private let examplesDir = "/Users/jiachenren/Library/Mobile Documents/com~apple~CloudDocs/Documents/Developer/Kelvin/Examples/"
    
    private func restoreDefault() {
        Variable.restoreDefault()
        Operation.restoreDefault()
        Keyword.restoreDefault()
    }
    
    func testSystemCheck() throws {
        let systemCheckUrl = examplesDir + "SystemCheck"
        let _ = try Compiler.compile("run \"\(systemCheckUrl)\"").simplify()
    }
    
    func testPerformance() {
        self.measure {
            restoreDefault()
            let systemCheckUrl = examplesDir + "SystemCheck"
            do {
                let _ = try Compiler.compile("run \"\(systemCheckUrl)\"").simplify()
            } catch let e as KelvinError {
                print(e.localizedDescription)
                XCTAssert(false)
            }
        }
        
    }

}
