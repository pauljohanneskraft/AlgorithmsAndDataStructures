//
//  BxTreeTests.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 03.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

class BxTreeTests: XCTestCase {
    func testStrings() {
        var tree = BxTree<String>(maxInnerNodeSize: 5, maxLeafNodeSize: 5)
        
        (0..<100).forEach {
            XCTAssertNotNil(try? tree.insert("\($0)"))
        }
        
        XCTAssertWillThrow(errors: [DataStructureError.alreadyIn]) {
            try tree.insert("15")
        }
        
        let str = "10"
        XCTAssertEqual(tree.find(key: str.hashValue), str)
        XCTAssertEqual(tree.count, 100)
        let arr = tree.array.flatMap({ Int($0) }).sorted()
        XCTAssertEqual(arr, [Int](0..<100))
    }
    
    func testInts() {
        var tree = BxTree<Int>(maxInnerNodeSize: 5, maxLeafNodeSize: 5)
        
        (0..<100).forEach {
            XCTAssertNotNil(try? tree.insert($0))
        }
        
        XCTAssertEqual(tree.find(key: 10), 10)
        
        XCTAssertEqual(tree.array.count, 100)
        XCTAssertEqual(tree.array, [Int](0..<100))
    }
}
