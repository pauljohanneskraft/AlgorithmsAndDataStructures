//
//  LinkedBxTreeTests.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 05.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

class LinkedBxTreeTests: XCTestCase {
    func test1() {
        let count = 200
        let array = (0..<count).shuffled()
        var tree = LinkedBxTree<Int>()
        tree.array = array
        var set = Set(array)
        let arr = (0..<(count >> 1)).map({ $0 * 2 }).shuffled()
        arr.forEach {
            XCTAssertEqual(tree.remove(at: $0), $0)
            set.remove($0)
            XCTAssertEqual(set.sorted(), tree.array)
        }
        print(tree.array)
    }
}
