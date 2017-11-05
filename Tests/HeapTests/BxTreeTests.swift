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
    
    var cacheLineSize: Int {
        var a: size_t = 0
        var b: size_t = MemoryLayout<Int>.size
        var c: size_t = 0
        sysctlbyname("hw.cachelinesize", &a, &b, &c, 0)
        return a
    }
    
    func testRemove() {
        testRemoval(tree: BxTree<Int>(maxInnerNodeSize: 5, maxLeafNodeSize: 3))
        testRemoval(tree: BxTree<Int>(maxInnerNodeSize: 20, maxLeafNodeSize: 3))
        testRemoval(tree: BxTree<Int>(maxInnerNodeSize: 3, maxLeafNodeSize: 20))
        testRemoval(tree: BxTree<Int>(
            maxInnerNodeSize: cacheLineSize / 8,
            maxLeafNodeSize: cacheLineSize / 8))
    }
    
    func testRemoval(tree: BxTree<Int>) {
        var tree = tree
        tree.removeAll()
        
        let count = 500
        
        (0..<count).shuffled().forEach {
            XCTAssert(tree.isValid)
            XCTAssertNotNil(try? tree.insert($0))
        }
        
        print("inserting done")
        
        (0..<(count >> 1)).map({ $0 * 2 }).shuffled().forEach {
            XCTAssertEqual(tree.remove($0), $0)
            XCTAssert(tree.isValid)
        }
        
        print("removing 1 done")
        
        (1..<(count >> 1)).map({ ($0 * 2) - 1 }).shuffled().forEach {
            XCTAssertNil(try? tree.insert($0))
        }
        
        print("reinserting 1 done")
        
        (0..<(count >> 1)).map({ $0 * 2 }).shuffled().forEach {
            XCTAssertNotNil(try? tree.insert($0))
        }
        
        print("reinserting 2 done")
        
        (0..<count).shuffled().forEach {
            XCTAssertEqual(tree.remove($0), $0)
            XCTAssert(tree.isValid)
        }
        
        print("done")
    }
    
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
