//
//  KelvinTests.swift
//  KelvinTests
//
//  Created by Jiachen Ren on 11/4/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import XCTest

class KelvinTests: XCTestCase {

    override func setUp() {
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
        return examplesUrl.path + "/SystemCheck.kel"
    }
    
    private func restoreDefault() {
        Variable.restoreDefault()
        Operation.restoreDefault()
        Syntax.restoreDefault()
    }
    
    func testCopy() {
        let fun = Function(.add, [1, 2])
        let list = List([1, 2])
        let vec = Vector([1, 2])
        let pair = Pair(1, 2)
        let eq = Equation(lhs: 1, rhs: 2)
        let revEq = eq.reversed()
        print(fun.stringified)
        assert(fun.copy() === fun)
        assert(fun.copy().stringified == fun.stringified)
        assert(fun !== list)
        assert(vec !== list)
        assert(vec.copy() === vec)
        assert(pair !== list)
        assert(pair === pair.copy())
        assert(eq !== pair)
        assert(eq === revEq)
        assert(Function(.add, [Function(.add, [1, 2]), 3]) === Function(.add, [1, 2, 3]))
    }
    
    func testSystemCheck() throws {
        do {
            let _ = try Compiler.shared.compile("run \"\(testUrl)\"").simplify()
        } catch let e as KelvinError {
            XCTFail(e.localizedDescription)
        }
    }
    
    /// Scheme for test should be RELEASE with DEBUG off.
    func testPerformance() {
        self.measure {
            do {
                let _ = try Compiler.shared.compile("run \"\(testUrl)\"").simplify()
            } catch let e as KelvinError {
                XCTFail(e.localizedDescription)
            } catch let e {
                XCTFail(e.localizedDescription)
            }
        }
    }

}
