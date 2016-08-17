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
	
	func testSinglyInsert() {
		let arr = [7263,6,35,473,5,4,36,456,2,7,23,1,67,45,7,43537,5,7]
		var sll = SinglyLinkedList<Int>()
		
		for i in arr.indices { try! sll.insert(arr[i], at: i) }
		
		do {
			try sll.insert(arr[0], at: arr.count + 1)
			XCTAssert(false)
		} catch let e {
			if let o = e as? ListError	{ XCTAssert(o == ListError.IndexOutOfRange) }
			else						{ XCTAssert(false) }
		}
		
		// print(sll.array)
		
		XCTAssert(sll.array == arr)
		
		for i in arr.indices {
			XCTAssert(arr[i] == sll[i])
			sll[i] = arr[i]
		}
		
		XCTAssert(sll.array == arr)
		
		var sllRev = [Int]()
		
		for i in arr.indices.reversed() {
			// print("will remove \(i):", arr[i])
			sllRev.append(try! sll.remove(at: i))
		}
		
		// print(sllRev)
		let arrRev : [Int] = arr.reversed()
		XCTAssert(sllRev == arrRev)
		
		for i in arrRev.indices { sll[i] = arrRev[i] }
		
		// print(sll.array)
		XCTAssert(sll.array == arrRev)
		
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
