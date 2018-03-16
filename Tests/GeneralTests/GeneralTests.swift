//
//  GeneralTests.swift
//  GeneralTests
//
//  Created by Paul Kraft on 02.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

class GeneralTests: XCTestCase {
    
    func testStringTimesUInt() {
        for char in "abcdefghijklmnopqrstuvwxyz.,:_".characters.map({ "\($0)" }) {
            let r = Int(arc4random() & 0xF)
            var res = ""
            for _ in 0..<r { res += char }
            let mul = char * r
            XCTAssertEqual(res, mul)
        }
    }
}
