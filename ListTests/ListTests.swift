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
	
	func testSingly() {
		insertAndRemove(using: SinglyLinkedList<Int>())
	}
	
	func testDoubly() {
		insertAndRemove(using: DoublyLinkedList<Int>())
	}
	
	func insertAndRemove<L : List>(using ll: L) where L.Element == Int {
		let arr = [7263,6,35,473,5,4,36,456,2,7,23,1,67,45,7,43537,5,7]
		
		var ll = ll
		
		for i in arr.indices { try! ll.insert(arr[i], at: i) }
		
		do {
			try ll.insert(arr[0], at: arr.count + 1)
			XCTAssert(false)
		} catch let e {
			if let o = e as? ListError	{ XCTAssert(o == ListError.IndexOutOfRange) }
			else						{ XCTAssert(false) }
		}
		
		print(ll.description)
		
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
		
	}
	
	func testSinglyLinkedList1() {
		let arr = [7263,6,35,473,5,4,36,456,2,7,23,1,67,45,7,43537,5,7]
		
		var sll = SinglyLinkedList<Int>()
		
		sll.array = arr
		
		// print(sll.array)
		// print(arr)
		
		XCTAssert(sll.array == arr)
		
		let arrRev : [Int] = arr.reversed()
		
		var sllRev = [Int]()
		
		while true {
			let n = sll.popBack()
			if n != nil { sllRev.append(n!) }
			else { break }
		}
		
		// print(sllRev)
		// print(arrRev)
		
		XCTAssert(sllRev == arrRev)
		
	}
	
}
