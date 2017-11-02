//
//  PatternMatchingTests.swift
//  PatternMatchingTests
//
//  Created by Paul Kraft on 02.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

class PatternMatchingTests: XCTestCase {
    
    func testNeedlemanWunsch() {
        
        let a = String.needlemanWunsch(comparing: "ACGTC", to: "AGTC")
        XCTAssertEqual("\(a)", "[(\"A-GTC\", \"ACGTC\")]")
        
        let b = String.needlemanWunsch(comparing: "GCATGCU", to: "GATTACA")
        let bStr = "[(\"G-ATTACA\", \"GCATG-CU\"), (\"G-ATTACA\", \"GCAT-GCU\"), (\"G-ATTACA\", \"GCA-TGCU\")]"
        XCTAssertEqual("\(b)", bStr)
        
        let c = String.needlemanWunsch(comparing: "Hallo", to: "Peter")
        XCTAssertEqual("\(c)", "[(\"Peter\", \"Hallo\")]")
        
        let d = String.needlemanWunsch(comparing: "Pinguin", to: "Julian",
                                       match: 3, mismatch: 1, insertion: 0, deletion: 0)
        XCTAssertEqual("\(d)", "[(\"J---ulian\", \"Pingu-i-n\")]")
        
        let e = String.needlemanWunsch(comparing: "MAEHTE", to: "AEHREN")
        XCTAssertEqual("\(e)", "[(\"-AEHREN\", \"MAEHTE-\")]")
        
    }
}
