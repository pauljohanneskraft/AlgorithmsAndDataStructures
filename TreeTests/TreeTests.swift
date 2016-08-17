//
//  TreeTests.swift
//  TreeTests
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import XCTest
import Algorithms_and_Data_structures

class TreeTests: XCTestCase {
    
	func testBinomialHeap() {
		var binHeap = BinomialHeap<Int>()
		let rdm = [9235,25,52,2,5,23,35,65,532,6,54,75,7,56,8,4]
		for r in rdm {
			print("\(r):", terminator: "")
			binHeap.insert(r)
			print(" ready.")
			print(binHeap)
		}
		print(binHeap.children)
		var binHeapArray = [Int]()
		for i in 0..<rdm.count {
			let min = binHeap.deleteMin()
			binHeapArray.append(min!)
			print("\(i):", min)
			print(binHeap)
		}
		XCTAssert(binHeapArray == rdm.sorted())
	}
		
}






