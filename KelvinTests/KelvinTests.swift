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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCompiler() {
        do {
            let compiled = try Compiler.compile("(3-a)*(c+b)/5+log(c)")
            print(compiled)
        } catch let err {
            print(err)
        }
    }
    
    func testNumericOperations() {
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
