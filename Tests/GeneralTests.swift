//
//  GeneralTests.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 19.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import XCTest
import Algorithms_and_Data_structures

class GeneralTests: XCTestCase {

	func testStringTimesUInt() {
		for char in "abcdefghijklmnopqrstuvwxyz.,:_".characters.map({ "\($0)" }) {
			let r = Int(arc4random() & 0xF)
			var res = ""
			for _ in 0..<r { res += char }
			let mul = char * r
			XCTAssert(res == mul, "\(res) != \(mul)")
		}
	}
	
	func testStringTimesUIntMethods() {
		func t1a (lhs: String, rhs: UInt) -> String {
			guard rhs > 1 else { guard rhs > 0 else { return "" }; return lhs }
			let result	= t1a(lhs: lhs, rhs: (rhs >> 1))
			let rest	= (rhs % 2 == 0 ? "" : lhs)
			return "\(result)\(result)\(rest)"
		}
		
		func t1b (lhs: String, rhs: UInt) -> String {
			guard rhs > 1 else { guard rhs > 0 else { return "" }; return lhs }
			let result	= t1b(lhs: lhs, rhs: (rhs >> 1))
			let rest	= (rhs % 2 == 0 ? "" : lhs)
			return result + result + rest
		}
		
		func t1c (lhs: String, rhs: UInt) -> String {
			guard rhs > 1 else { guard rhs > 0 else { return "" }; return lhs }
			let result	= t1c(lhs: lhs, rhs: (rhs >> 1))
			guard rhs & 0x1 == 0 else { return result + result + lhs }
			return result + result
		}
		
		func t2 (lhs: String, rhs: UInt) -> String {
			var result = ""
			for _ in 0..<rhs { result += lhs }
			return result
		}
		
		var f1a = 0.0
		var f1b = 0.0
		var f1c = 0.0
		// var f2  = 0.0
		
		for _ in 0..<100 {
			print(".", terminator: "")
			
			let string	: String	= "abcdefghijklmnopqrstuvwxyz"
			let num		: UInt		= UInt(arc4random()) & 0xFFFF
			let result	: String	= string * num
			
			f1a += measureTime { XCTAssert(result == t1a(lhs: string, rhs: num)) }
			f1b += measureTime { XCTAssert(result == t1b(lhs: string, rhs: num)) }
			f1c += measureTime { XCTAssert(result == t1c(lhs: string, rhs: num)) }
			// f2  += measureTime { XCTAssert(result == t2 (lhs: string, rhs: num)) }
			
		}
		print()
		print("1a", f1a)
		print("1b", f1b)
		print("1c", f1c)
		
		
	}
}

private func measureTime(_ f: () -> ()) -> Double {
	let s = NSDate()
	f()
	return -s.timeIntervalSinceNow
}
