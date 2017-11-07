//
//  DataStructureTests.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 06.11.17.
//

import XCTest
import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

class DataStructureTests: XCTestCase {

    func test<D: DataStructure>(structure: D) where D.DataElement == Int {
        var structure = structure
        structure.removeAll()
        XCTAssertEqual(structure.count, 0)
        
        let count = 200
        var array = [Int]()
        
        (0..<count).shuffled().forEach {
            XCTAssertNotNil(try? structure.insert($0))
            array.append($0)
            XCTAssertEqual(array.count, Int(structure.count))
            XCTAssertEqual(structure.array.count, Int(structure.count))
            XCTAssertEqual(array.sorted(), structure.array.sorted())
        }
        
        (0..<(count >> 1)).map({ $0 * 2 }).shuffled().forEach {
            XCTAssertNil(try? structure.insert($0))
            XCTAssertEqual(array.count, Int(structure.count))
            XCTAssertEqual(structure.array.count, Int(structure.count))
            XCTAssertEqual(array.sorted(), structure.array.sorted())
        }
        (1..<(count >> 1)).map({ ($0 * 2) - 1 }).shuffled().forEach {
            XCTAssertNotNil(try? structure.remove($0))
            array.remove($0)
            XCTAssertEqual(array.count, Int(structure.count))
            XCTAssertEqual(structure.array.count, Int(structure.count))
            XCTAssertEqual(array.sorted(), structure.array.sorted())
        }
        
        print(type(of: structure), "done.")
    }
    
    func testAll() {
        test(structure: BinaryTree<Int>())
        test(structure: CompositeBinaryTree<Int>())
        test(structure: AVLBinaryTree<Int>())
        test(structure: AVLCompositeBinaryTree<Int>())
        test(structure: BTree<Int>(maxNodeSize: 10))
        test(structure: BxTree<Int>())
        test(structure: LinkedBxTree<Int>())
    }

}
