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
	
}
