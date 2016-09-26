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
		XCTAssert(String.needlemanWunsch(comparing: "ACGTC", to: "AGTC").description == "[(\"A-GTC\", \"ACGTC\")]")
		XCTAssert(String.needlemanWunsch(comparing: "GCATGCU", to: "GATTACA").description == "[(\"G-ATTACA\", \"GCATG-CU\"), (\"G-ATTACA\", \"GCAT-GCU\"), (\"G-ATTACA\", \"GCA-TGCU\")]")
		XCTAssert(String.needlemanWunsch(comparing: "Hallo", to: "Peter").description == "[(\"Peter\", \"Hallo\")]")
		XCTAssert(String.needlemanWunsch(comparing: "Pinguin", to: "Julian", match: 3, mismatch: 1, insertion: 0, deletion: 0).description == "[(\"J---ulian\", \"Pingu-i-n\")]")

	}
}
