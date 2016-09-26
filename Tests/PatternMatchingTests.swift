//
//  PatternMatchingTests.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 26.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import XCTest

class PatternMatchingTests: XCTestCase {

	func testNeedlemanWunsch() {
		
		let a = String.needlemanWunsch(comparing: "ACGTC", to: "AGTC")
		XCTAssert("\(a)" == "[(\"A-GTC\", \"ACGTC\")]", "\(a)")
		
		let b = String.needlemanWunsch(comparing: "GCATGCU", to: "GATTACA")
		XCTAssert("\(b)" == "[(\"G-ATTACA\", \"GCATG-CU\"), (\"G-ATTACA\", \"GCAT-GCU\"), (\"G-ATTACA\", \"GCA-TGCU\")]", "\(b)")
		
		let c = String.needlemanWunsch(comparing: "Hallo", to: "Peter")
		XCTAssert("\(c)" == "[(\"Peter\", \"Hallo\")]", "\(c)")
		
		let d = String.needlemanWunsch(comparing: "Pinguin", to: "Julian", match: 3, mismatch: 1, insertion: 0, deletion: 0)
		XCTAssert("\(d)" == "[(\"J---ulian\", \"Pingu-i-n\")]", "\(d)")
		
		let e = String.needlemanWunsch(comparing: "MAEHTE", to: "AEHREN")
		XCTAssert("\(e)" == "[(\"-AEHREN\", \"MAEHTE-\")]", "\(e)")

	}
}
