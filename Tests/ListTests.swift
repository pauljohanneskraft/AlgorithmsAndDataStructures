//
//  ListTests.swift
//  ListTests
//
//  Created by Paul Kraft on 17.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import XCTest
import Algorithms_and_Data_structures

class ListTests: XCTestCase {
	
	override func setUp() {
		arrs = []
		for _ in 0..<30 {
			var arr = [Int]()
			for _ in 0..<20 {
				arr.append(Int(arc4random() & 0xFFF))
			}
			arrs.append(arr)
		}
	}
	
	var arrs : [[Int]] = []
	
	func testSingly() {
		insertAndRemove(using: SinglyLinkedList<Int>.self)
	}
	
	func testDoubly() {
		insertAndRemove(using: DoublyLinkedList<Int>.self)
	}
	
	func insertAndRemove<L : List>(using ll: L.Type) where L.Element == Int {
		for arr in arrs {
			var ll = L.init()
			
			for i in arr.indices { try! ll.insert(arr[i], at: i) }
			
			do {
				try ll.insert(arr[0], at: arr.count + 1)
				XCTAssert(false)
			} catch let e {
				if let o = e as? ListError	{ XCTAssert(o == ListError.IndexOutOfRange) }
				else						{ XCTAssert(false) }
			}
			
			// print(ll.description)
			
			XCTAssert(ll.count == arr.count)
			XCTAssert(ll.array == arr)
			
			for i in arr.indices {
				XCTAssert(arr[i] == ll[i])
				ll[i] = arr[i]
			}
			
			XCTAssert(ll.array == arr)
			
			var llRev = [Int]()
			
			for i in arr.indices.reversed() {
				// print("will remove \(i):", arr[i])
				llRev.append(try! ll.remove(at: i))
			}
			
			XCTAssert(ll.count == 0)
			
			// print(sllRev)
			let arrRev : [Int] = arr.reversed()
			XCTAssert(llRev == arrRev)
			
			for i in arrRev.indices { ll[i] = arrRev[i] }
			
			// print(sll.array)
			XCTAssert(ll.array == arrRev)
			
			var arr2 = [Int]()
			
			for _ in arrRev.indices {
				arr2.append(ll.popBack()!)
			}
			
			XCTAssert(arr2 == arr)
			XCTAssert(ll.count == 0)
			
			for e in arr {
				ll.pushBack(e)
			}
			
			XCTAssert(ll.array == arr, "\(ll.array) != \(arr)")
		}
		
		let l : L = [1,2,3]
		if L.self == SinglyLinkedList<Int>.self {
			XCTAssert(l.description == "[1 -> 2 -> 3]")
		} else if L.self == DoublyLinkedList<Int>.self {
			XCTAssert(l.description == "[1 <-> 2 <-> 3]")
		} else {
			XCTAssert(false, "add this type")
		}
	}
	
    func testLazyLists() {
        var interval = [Int]()
        for _ in 0..<200 {
            interval.append(Int(arc4random() % 300))
        }
        let start1 = Date()
        let lpowers2 = LazyList<Int>(start: 1) { (a: Int) -> Int in return a + 2 }
        for i in interval { _ = lpowers2[i] }
        for i in interval { _ = lpowers2[i] }
        let negation = LazyList<Bool>(start: false) { !$0 }
        for i in interval { _ = negation[i] }
        for i in interval { _ = negation[i] }
        print(Date().timeIntervalSince(start1))
        let start2 = Date()
        let lpowers2buff = BufferedLazyList<Int>(start: 1) { (a: Int) -> Int in return a + 2 }
        for i in interval { _ = (lpowers2buff[i]) }
        for i in interval { _ = (lpowers2buff[i]) }
        let negationbuff = BufferedLazyList<Bool>(start: false) { !$0 }
        for i in interval { _ = (negationbuff[i]) }
        for i in interval { _ = (negationbuff[i]) }
        print(Date().timeIntervalSince(start2))
        let start3 = Date()
        let lpowers2sbuff = SmartBufferedLazyList<Int>(start: 1) { (a: Int) -> Int in return a + 2 }
        for i in interval { _ = (lpowers2sbuff[i]) }
        for i in interval { _ = (lpowers2sbuff[i]) }
        let negationsbuff = SmartBufferedLazyList<Bool>(start: false) { !$0 }
        for i in interval { _ = (negationsbuff[i]) }
        for i in interval { _ = (negationsbuff[i]) }
        print(Date().timeIntervalSince(start3))
        for i in interval {
            let nb = lpowers2[i]
            let db = lpowers2buff[i]
            let sd = lpowers2sbuff[i]
            XCTAssert(nb == db && nb == sd)
            // print(i, nb, db, sd)
        }
        let minus1      = lpowers2      .lazymap { $0 - 3 }
        var min1buffer  = lpowers2buff  .lazymap { $0 - 3 }
        var min1sbuff   = lpowers2sbuff .lazymap { $0 - 3 }
        XCTAssert(minus1.startIndex == 0)
        XCTAssert(min1buffer.startIndex == 0)
        XCTAssert(min1sbuff.startIndex == 0)
        XCTAssert(minus1.endIndex == Int.max)
        XCTAssert(min1buffer.endIndex == Int.max)
        XCTAssert(min1sbuff.endIndex == Int.max)
        XCTAssert(minus1.count == Int.max)
        XCTAssert(min1buffer.count == Int.max)
        XCTAssert(min1sbuff.count == Int.max)
        XCTAssert(minus1.get(first: 10) == min1buffer.get(first: 10))
        XCTAssert(min1sbuff.get(first: 10) == min1sbuff.get(first: 10))
        XCTAssert(min1buffer.bufferCount > 0)
        XCTAssert(min1sbuff.bufferCount > 0)
        min1buffer.clearBuffer()
        min1sbuff.clearBuffer()
        XCTAssert(min1buffer.bufferCount == 1)
        XCTAssert(min1sbuff.bufferCount == 1)
        XCTAssert(min1sbuff.first == min1buffer.first)
        for i in interval {
            let nb = lpowers2[i]
            let db = lpowers2buff[i]
            let sd = lpowers2sbuff[i]
            XCTAssert(nb == db && nb == sd)
            // print(i, nb, db, sd)
        }
        var l1 = lpowers2sbuff
        var l2 = lpowers2buff
        XCTAssert(l1.bufferCount > 10)
        XCTAssert(l2.bufferCount > 10)
        l1.reduceBufferSize(to: 9)
        l2.reduceBufferSize(to: 9)
        XCTAssert(l1.bufferCount == 9)
        XCTAssert(l2.bufferCount == 9)
        l1.reduceBufferSize(to: 0)
        l2.reduceBufferSize(to: 0)
        XCTAssert(l1.bufferCount == 1)
        XCTAssert(l2.bufferCount == 1)
    }
    /*
    func testCollatz() {
        func collatz(of num: Int) -> Int {
            if num & 0x1 == 0 {
                return num >> 1
            } else {
                return 3*num + 1
            }
        }
        
        var endresults = Set([1])
        
        for i in 1..<Int.max {
            var res = [i]
            var accu = i
            while !endresults.contains(accu) {
                accu = collatz(of: accu)
                res.append(accu)
            }
            if i & 0xFFFFFF == 0 { print(i) }
            endresults.formUnion(Set(res))
        }
    }
 */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
