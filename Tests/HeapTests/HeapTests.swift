//
//  HeapTests.swift
//  HeapTests
//
//  Created by Paul Kraft on 02.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable identifier_name force_try line_length
// swiftlint:disable trailing_whitespace comma cyclomatic_complexity
// swiftlint:disable colon function_body_length unused_closure_parameter

class HeapTests: XCTestCase {
    
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
        XCTAssertNil(BTree<Int>(maxNodeSize: 2))
        for i in [3, 6, 7] {
            btree = BTree<Int>(maxNodeSize: i)!
            btree.replace(2)
            print(btree)
            btree.remove(hashValue: 2)
            print(btree)
            try! btree.insert(2)
            let interval = 0..<50
            for i in interval { try? btree.insert(i) }
            XCTAssertEqual(btree.count, 50)
            let minSize = (i + 1) / 2
            let minHeight = Int(round(log(51.0) / log(Double(i))) + 1) - 1
            let maxHeight = Int(round(log(25.0) / log(Double(minSize))))
            let bheight = btree.height
            XCTAssert(bheight >= minHeight || bheight <= maxHeight, "\(bheight) \(minHeight) \(maxHeight) \(i)")
            print(btree)
            for i in interval.reversed() {
                // print(i, btree)
                XCTAssertEqual(i, btree.remove(hashValue: i)!)
            }
            XCTAssertEqual(btree.count, 0)
            XCTAssertEqual(btree.height, 0)
            
            for i in interval { btree.replace(i) }
            
            XCTAssertNil(try? btree.insert(47))
            
            let bheight2 = btree.height
            XCTAssert(bheight2 >= minHeight || bheight2 <= maxHeight, "\(bheight2) \(minHeight) \(maxHeight) \(i)")
            
            for i in interval.reversed() {
                // print(i, btree)
                XCTAssertEqual(i, btree.remove(hashValue: i)!)
            }
            XCTAssertEqual(btree.count, 0)
            XCTAssertEqual(btree.height, 0)
            
            var insertArray = Set<Int>()
            for arr in arrs.dropLast(20) {
                for r in arr { insertArray.insert(r) }
            }
            var count = 0
            for r in insertArray.sorted(by: { a, b in arc4random() & 0x1 == 0 }) {
                count += 1
                try! btree.insert(r)
                XCTAssertEqual(btree.count, count)
            }
            for r in insertArray.sorted(by: { a, b in arc4random() & 0x1 == 0 }) {
                XCTAssert(btree.contains(r))
            }
            let barray = btree.array
            let sarray = insertArray.sorted()
            XCTAssertEqual(barray, sarray)
            btree.array = sarray
            for r in insertArray.sorted(by: { a, b in arc4random() & 0x1 == 0 }) {
                let countBefore = btree.count
                XCTAssertEqual(btree[r], r)
                btree.replace(r)
                XCTAssertEqual(btree.count, countBefore)
            }
            for _ in 0..<100 {
                let countBefore = btree.count
                var r = Int(arc4random() & 0xFFFF)
                while insertArray.contains(r) {
                    r = Int(arc4random() & 0xFFFF)
                }
                XCTAssert(!btree.contains(r))
                XCTAssertNil(btree[r])
                XCTAssertNil(btree.remove(hashValue: r))
                XCTAssertEqual(btree.count, countBefore)
            }
            print(btree)
            for r in insertArray.sorted(by: { a, b in arc4random() & 0x1 == 0 }) {
                count -= 1
                let res = btree.remove(hashValue: r)
                XCTAssertEqual(count, btree.count)
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
            XCTAssertEqual(binHeap.children.count, arr.count.bitCount)
            var binHeapArray = [Int]()
            for _ in arr.indices {
                let min = binHeap.pop()!
                binHeapArray.append(min)
                // print("\(i):", min)
                // print(binHeap)
            }
            print(binHeapArray)
            XCTAssertEqual(binHeapArray, arr.sorted())
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
            XCTAssertEqual(sorted, revSorted)
            XCTAssertEqual(sorted2.count, revSorted.count, "counts don't match.")
            XCTAssertEqual(sorted2, revSorted)
        }
    }
    
    func testTrie() {
        let a = Array("Hallo".characters)
        let b = Array("Hello".characters)
        let c = Array("Bonjour".characters)
        var list = [a, b, c]
        Trie<Character>.sort(&list)
        XCTAssertEqual("\(list)", "[[\"B\", \"o\", \"n\", \"j\", \"o\", \"u\", \"r\"], [\"H\", \"a\", \"l\", \"l\", \"o\"], [\"H\", \"e\", \"l\", \"l\", \"o\"]]")
        var t = Trie<Character>()
        t.insert(a)
        t.insert(a)
        t.insert(a.dropLast() + [])
        t.insert(b)
        t.insert(c)
        print(t.count)
        XCTAssertEqual("\(t.description)", "Trie<Character>\n ∟ B\n  ∟ o\n   ∟ n\n    ∟ j\n     ∟ o\n      ∟ u\n       ∟ r - 1\n ∟ H\n  ∟ a\n   ∟ l\n    ∟ l - 1\n     ∟ o - 2\n  ∟ e\n   ∟ l\n    ∟ l\n     ∟ o - 1")
        var t2 = Trie<Character>()
        try? t.remove(a)
        print(t.description)
        try? t.remove(a.dropLast() + [])
        print(t.description)
        try? t.remove(a)
        print(t.description)
        t2.insert(Array("Peter".characters))
        t2.merge(with: t)
        print(t2.description)
        let t2array = t2.array(sortedBy: <).map { String($0) }
        XCTAssertEqual(t2array, ["Bonjour", "Hello", "Peter"])
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
        XCTAssertEqual("\(ab)", "[[7, 22, 5], [7, 21, 6]]")
        Trie<TestTrieComparable>.sort(&ab, by: { $0.hashValue < $1.hashValue })
        XCTAssertEqual("\(ab)", "[[7, 21, 6], [7, 22, 5]]")
    }
    
    func testBinaryTree<T: Tree>(type: T.Type) where T.Element == Int {
        for arr in arrs {
            var bin = T.init()
            
            for e in arr {
                XCTAssertNotNil(try? bin.push(e))
                print(bin.array)
            }
            
            var a = bin.array
            
            var sorted = arr.sorted()
            
            XCTAssertEqual(a, sorted)
            
            print("before pop()", bin)
            
            let p = bin.pop()
            
            XCTAssertEqual(p, sorted[0])
            
            _ = sorted.remove(at: 0)
            a = bin.array
            
            XCTAssertEqual(a, sorted)
            print("after pop()", bin)
        }
    }
    
    func testBinaryTrees() {
        testBinaryTree(type: BinaryTree<Int>.self)
        testBinaryTree(type: CompositeBinaryTree<Int>.self)
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
