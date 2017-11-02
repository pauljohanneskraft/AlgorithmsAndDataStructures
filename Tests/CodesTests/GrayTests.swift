//
//  GrayTests.swift
//  CodesTests
//
//  Created by Paul Kraft on 01.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

class GrayTests: XCTestCase {

    func test0() {
        let count = 10_000
        for i in 0..<(count >> 1) { test(i)                   }
        for _ in 0..<(count >> 1) { test(Int(arc4random()))   }
    }
    
    func test(_ number: Int) {
        let code = number.grayCode
        let int = Int(grayCode: code)
        XCTAssertEqual(number, int)
        
        let inc = (number + 1).grayCode
        let hammDistance = code.hammingDistance(to: inc)
        XCTAssertEqual(hammDistance, 1)
    }

}
