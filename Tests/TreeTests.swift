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
	
	override func setUp() {
		arrs = []
		for _ in 0..<30 {
			var arr = [Int]()
			for _ in 0..<30 {
				arr.append(Int(arc4random() & 0xFFF))
			}
			arrs.append(arr)
		}
		arrs.append([1,2,3])
	}
	
	var arrs : [[Int]] = []
	
	// let arr = [9235,25,52,2,5,23,35,65,532,6,54,75,7,56,8,4]
	
	func testBinomialHeap() {
		for arr in arrs {
			var binHeap = BinomialHeap<Int>()
			for r in arr {
				// print("\(r):", terminator: "")
				binHeap.push(r)
				// print(" ready.")
				// print(binHeap)
			}
			print(binHeap)
			XCTAssert(binHeap.children.count == arr.count.bitCount)
			var binHeapArray = [Int]()
			for _ in arr.indices {
				let min = binHeap.pop()!
				binHeapArray.append(min)
				// print("\(i):", min)
				// print(binHeap)
			}
			print(binHeapArray)
			XCTAssert(binHeapArray == arr.sorted())
		}
	}
	
	func testMaxHeap() {
		for arr in arrs {
			var maxHeap = BinaryMaxHeap<Int>()
			
			maxHeap.array = arr
			
			var heap2 = BinaryMaxHeap<Int>()
			
			for e in arr {
				heap2.push(e)
			}
			
			var sorted = [Int]()
			var sorted2 = [Int]()
			
			for _ in arr.indices {
				sorted.append(maxHeap.pop()!)
				sorted2.append(heap2.pop()!)
			}
			// print(sorted)
			let revSorted : [Int] = arr.sorted().reversed()
			XCTAssert(sorted	== revSorted, "\n\(sorted	)\n!=\n\(revSorted	)\n")
			// XCTAssert(sorted2	== revSorted, "\n\(sorted2	)\n!=\n\(revSorted	)\n")
			// XCTAssert(sorted	== sorted2	, "\n\(sorted	)\n!=\n\(sorted2	)\n") // HIGH_PRIO
			if sorted2 == revSorted { print(sorted2) }
		}
	}
	
	func testBinaryTree() {
		for arr in arrs {
			var bin = BinaryTree<Int>()
			
			for e in arr { bin.push(e) }
			
			var a = bin.array
			
			var sorted = arr.sorted()
			
			XCTAssert(a == sorted,		"\(bin): array not sorted. \(a) != \(sorted)"		)
			
			let p = bin.pop()
			
			XCTAssert(p == sorted[0],	"\(bin): pop() failed.     \(p) != \(sorted[0])"	)
			
			_ = sorted.remove(at: 0)
			a = bin.array
			
			XCTAssert(a == sorted,		"\(bin): array not sorted. \(a) != \(sorted)"		)
		}
	}
}


extension Int {
	var bitCount : Int {
		var this = self
		var c = 0
		while this != 0 {
			if this & 0x1 == 1 { c += 1 }
			this = this >> 1
		}
		return c
	}
}
