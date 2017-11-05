//
//  BxTreeLinkedTests.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 05.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

class BxTreeLinkedTests: XCTestCase {
    func test1() {
        let count = 200
        let array = (0..<count).shuffled()
        var tree = BxTreeLinked<Int>()
        tree.array = array
        let arr = (0..<(count >> 1)).map({ $0 * 2 }).shuffled()
        arr.forEach {
            XCTAssertEqual(tree.remove($0), $0)
        }
        print(tree.array)
        let rest = Set(array).subtracting(Set(arr)).sorted()
        XCTAssertEqual(tree.array, rest)
    }
}
