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
    
    func testBTree() {
        var btree = BTree<Int>(maxNodeSize: 5)!
        XCTAssert(BTree<Int>(maxNodeSize: 2) == nil)
        for i in [3, 6, 7] {
            btree = BTree<Int>(maxNodeSize: i)!
            btree.replace(2)
            print(btree)
            btree.remove(hashValue: 2)
            print(btree)
            try! btree.insert(2)
            let interval = 0..<50
            for i in interval { try? btree.insert(i) }
            XCTAssert(btree.count == 50)
            let minSize = (i + 1) / 2
            let minHeight = Int(round(log(51.0) / log(Double(i))) + 1) - 1
            let maxHeight = Int(round(log(25.0) / log(Double(minSize))))
            let bheight = btree.height
            XCTAssert(bheight >= minHeight || bheight <= maxHeight, "\(bheight) \(minHeight) \(maxHeight) \(i)")
            print(btree)
            for i in interval.reversed() {
                // print(i, btree)
                XCTAssert(i == btree.remove(hashValue: i)!)
            }
            XCTAssert(btree.count == 0)
            XCTAssert(btree.height == 0)
            
            for i in interval { btree.replace(i) }
            
            let a = (try? btree.insert(47)) == nil
            XCTAssert(a)
            
            let bheight2 = btree.height
            XCTAssert(bheight2 >= minHeight || bheight2 <= maxHeight, "\(bheight2) \(minHeight) \(maxHeight) \(i)")
            
            for i in interval.reversed() {
                // print(i, btree)
                XCTAssert(i == btree.remove(hashValue: i)!)
            }
            XCTAssert(btree.count == 0)
            XCTAssert(btree.height == 0)
            
            var insertArray = Set<Int>()
            for arr in arrs.dropLast(20) {
                for r in arr { insertArray.insert(r) }
            }
            var count = 0
            for r in insertArray.sorted(by: { a, b in arc4random() & 0x1 == 0 }) {
                count += 1
                try! btree.insert(r)
                XCTAssert(btree.count == count)
            }
            for r in insertArray.sorted(by: { a, b in arc4random() & 0x1 == 0 }) {
                XCTAssert(btree.contains(r))
            }
            let barray = btree.array
            let sarray = insertArray.sorted()
            XCTAssert(barray == sarray, "\(barray) != \(sarray)")
            btree.array = sarray
            for r in insertArray.sorted(by: { a, b in arc4random() & 0x1 == 0 }) {
                let countBefore = btree.count
                XCTAssert(btree[r] == r)
                btree.replace(r)
                XCTAssert(btree.count == countBefore)
            }
            for _ in 0..<100 {
                let countBefore = btree.count
                var r = Int(arc4random() & 0xFFFF)
                while insertArray.contains(r) {
                    r = Int(arc4random() & 0xFFFF)
                }
                XCTAssert(!btree.contains(r))
                XCTAssert(btree[r] == nil)
                XCTAssert(btree.remove(hashValue: r) == nil)
                XCTAssert(btree.count == countBefore)
            }
            print(btree)
            for r in insertArray.sorted(by: { a, b in arc4random() & 0x1 == 0 }) {
                count -= 1
                let res = btree.remove(hashValue: r)
                XCTAssert(count == btree.count)
                XCTAssert(res != nil && r == res!)
            }
            
            for r in insertArray {
                XCTAssert(!btree.contains(r))
            }
            
            try! btree.insert(2)
            print(btree)
        }
    }
	
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
        print(t.count)
		XCTAssert("\(t.description)" == "Trie<Character>\n ∟ B\n  ∟ o\n   ∟ n\n    ∟ j\n     ∟ o\n      ∟ u\n       ∟ r - 1\n ∟ H\n  ∟ a\n   ∟ l\n    ∟ l - 1\n     ∟ o - 2\n  ∟ e\n   ∟ l\n    ∟ l\n     ∟ o - 1", "\(t.description)")
        try? t.remove(a)
        print(t.description)
        try? t.remove(a.dropLast() + [])
        print(t.description)
        try? t.remove(a)
        print(t.description)
        try? t.remove(b)
        print(t.description)
        try? t.remove(c)
        print(t.description)
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

