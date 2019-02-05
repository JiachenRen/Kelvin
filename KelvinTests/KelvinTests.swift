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
    
    private let examplesUrl = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Examples")
    
    private var testUrl: String {
        return examplesUrl.path + "/SystemCheck"
    }
    
    private func restoreDefault() {
        Variable.restoreDefault()
        Operation.restoreDefault()
        Keyword.restoreDefault()
    }
    
    func testSystemCheck() throws {
        do {
            let _ = try Compiler.compile("run \"\(testUrl)\"").simplify()
        } catch let e as KelvinError {
            XCTFail(e.localizedDescription)
        }
    }
    
    func testPerformance() {
        self.measure {
            restoreDefault()
            
            do {
                let _ = try Compiler.compile("run \"\(testUrl)\"").simplify()
            } catch let e as KelvinError {
                XCTFail(e.localizedDescription)
            } catch let e {
                XCTFail(e.localizedDescription)
            }
        }
    }

}
