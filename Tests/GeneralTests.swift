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
}
