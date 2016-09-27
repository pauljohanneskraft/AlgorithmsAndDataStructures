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
			XCTAssert(sorted2.count	== revSorted.count, "counts don't match.")
			XCTAssert(sorted2	== revSorted, "\n\(sorted2	)\n!=\n\(revSorted	)\n")
		}
	}
	
	func testTrie() {
		let a = "Hallo".characters.map { $0 }
		let b = "Hello".characters.map { $0 }
		let c = "Bonjour".characters.map { $0 }
		var list = [a, b, c]
		Trie<Character>.sort(&list)
		XCTAssert("\(list)" == "[[\"B\", \"o\", \"n\", \"j\", \"o\", \"u\", \"r\"], [\"H\", \"a\", \"l\", \"l\", \"o\"], [\"H\", \"e\", \"l\", \"l\", \"o\"]]")
		let t = Trie<Character>()
		t.insert(a)
		t.insert(a)
		t.insert(a.dropLast() + [])
		t.insert(b)
		t.insert(c)
		XCTAssert("\(t)" == "Trie<Character>\n ∟ B\n  ∟ o\n   ∟ n\n    ∟ j\n     ∟ o\n      ∟ u\n       ∟ r - 1\n ∟ H\n  ∟ a\n   ∟ l\n    ∟ l - 1\n     ∟ o - 2\n  ∟ e\n   ∟ l\n    ∟ l\n     ∟ o - 1", "\(t)")
	}
	
	func testTrieComparable() {
		let a = [TestTrieComparable(hashValue: 7), TestTrieComparable(hashValue: 22), TestTrieComparable(hashValue: 5)]
		let b = [TestTrieComparable(hashValue: 7), TestTrieComparable(hashValue: 21), TestTrieComparable(hashValue: 6)]
		var ab = [a, b]
		Trie<TestTrieComparable>.sort(&ab)
		XCTAssert("\(ab)" == "[[7, 22, 5], [7, 21, 6]]")
		Trie<TestTrieComparable>.sort(&ab, by: { $0.hashValue < $1.hashValue })
		XCTAssert("\(ab)" == "[[7, 21, 6], [7, 22, 5]]")
	}
	
	func testBinaryTree() {
		for arr in arrs {
			var bin = BinaryTree<Int>()
			
			for e in arr { bin.push(e) }
			
			var a = bin.array
			
			var sorted = arr.sorted()
			
			XCTAssert(a == sorted,		"\(bin): array not sorted. \(a) != \(sorted)"		)
			
			print("before pop()", bin)
			
			let p = bin.pop()
			
			XCTAssert(p == sorted[0],	"\(bin): pop() failed.     \(p) != \(sorted[0])"	)
			
			_ = sorted.remove(at: 0)
			a = bin.array
			
			XCTAssert(a == sorted,		"\(bin): array not sorted. \(a) != \(sorted)"		)
			print("after pop()", bin)
		}
	}
}

struct TestTrieComparable : Comparable, Hashable, CustomStringConvertible {
	init() { self.init(hashValue: Int(arc4random())) }
	init(hashValue: Int) { self.hashValue = hashValue }
	var hashValue: Int = Int(arc4random())
	var description: String { return hashValue.description }
}

func < (lhs: TestTrieComparable, rhs: TestTrieComparable) -> Bool {
	return lhs.hashValue > rhs.hashValue
}

func == (lhs: TestTrieComparable, rhs: TestTrieComparable) -> Bool {
	return lhs.hashValue == rhs.hashValue
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

