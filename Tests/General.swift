//
//  General.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 02.11.17.
//

import XCTest

func XCTAssertWillThrow(_ block: () throws -> Void) {
    XCTAssertMayThrow {
        try block()
        XCTFail("Did not throw error.")
    }
}

func XCTAssertMayThrow(_ block: () throws -> Void) {
    do {
        try block()
    } catch {}
}

func XCTAssertWillThrow<E: Error & Equatable>(errors: [E], block: () throws -> Void) {
    XCTAssertMayThrow(errors: errors) {
        try block()
        XCTFail("Did not throw error.")
    }
}

func XCTAssertMayThrow<E: Error & Equatable>(errors: [E], block: () throws -> Void) {
    do {
        try block()
    } catch let thrownError as E {
        XCTAssert(errors.contains(thrownError), "Incorrect error thrown. (\(thrownError))")
    } catch let thrownError {
        XCTFail("Incorrect error thrown (\(thrownError))")
    }
}

func XCTAssertEqualOptional<Wrapped: Equatable>(_ exp1: Wrapped?, _ exp2: Wrapped) {
    guard let exp1 = exp1 else {
        XCTAssertNotNil(nil)
        return
    }
    XCTAssertEqual(exp1, exp2)
}

func XCTAssertEqualOptional<Wrapped: Equatable>(_ exp1: Wrapped, _ exp2: Wrapped?) {
    XCTAssertEqualOptional(exp2, exp1)
}
