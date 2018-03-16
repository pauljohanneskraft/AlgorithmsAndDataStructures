//
//  LazyListTests.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 02.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

class LazyListTests: XCTestCase {

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func testLazyLists() {
        var interval = [Int]()
        for _ in 0..<200 {
            interval.append(Int(arc4random() % 300))
        }
        let start1 = Date()
        let lpowers2 = LazyList<Int>(start: 1) { $0 + 2 }
        for i in interval { _ = lpowers2[i] }
        for i in interval { _ = lpowers2[i] }
        let negation = LazyList<Bool>(start: false) { !$0 }
        for i in interval { _ = negation[i] }
        for i in interval { _ = negation[i] }
        print(Date().timeIntervalSince(start1))
        let start2 = Date()
        let lpowers2buff = BufferedLazyList<Int>(start: 1) { $0 + 2 }
        for i in interval { _ = (lpowers2buff[i]) }
        for i in interval { _ = (lpowers2buff[i]) }
        let negationbuff = BufferedLazyList<Bool>(start: false) { !$0 }
        for i in interval { _ = (negationbuff[i]) }
        for i in interval { _ = (negationbuff[i]) }
        print(Date().timeIntervalSince(start2))
        let start3 = Date()
        let lpowers2sbuff = SmartBufferedLazyList<Int>(start: 1) { $0 + 2 }
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
            XCTAssertEqual(nb, db)
            XCTAssertEqual(nb, sd)
            // print(i, nb, db, sd)
        }
        let minus1      = lpowers2      .lazymap { $0 - 3 }
        var min1buffer  = lpowers2buff  .lazymap { $0 - 3 }
        var min1sbuff   = lpowers2sbuff .lazymap { $0 - 3 }
        XCTAssertEqual(minus1.startIndex, 0)
        XCTAssertEqual(min1buffer.startIndex, 0)
        XCTAssertEqual(min1sbuff.startIndex, 0)
        XCTAssertEqual(minus1.endIndex, Int.max)
        XCTAssertEqual(min1buffer.endIndex, Int.max)
        XCTAssertEqual(min1sbuff.endIndex, Int.max)
        XCTAssertEqual(minus1.count, Int.max)
        XCTAssertEqual(min1buffer.count, Int.max)
        XCTAssertEqual(min1sbuff.count, Int.max)
        XCTAssertEqual(minus1.get(first: 10), min1buffer.get(first: 10))
        XCTAssertEqual(min1sbuff.get(first: 10), min1sbuff.get(first: 10))
        XCTAssert(min1buffer.bufferCount > 0)
        XCTAssert(min1sbuff.bufferCount > 0)
        min1buffer.clearBuffer()
        min1sbuff.clearBuffer()
        XCTAssertEqual(min1buffer.bufferCount, 1)
        XCTAssertEqual(min1sbuff.bufferCount, 1)
        XCTAssertEqual(minus1.first, min1buffer.first)
        XCTAssertEqual(min1sbuff.first, min1buffer.first)
        XCTAssertEqual(minus1.index(after: 24), 25)
        XCTAssertEqual(min1buffer.index(after: 24), 25)
        XCTAssertEqual(min1sbuff.index(after: 24), 25)
        for i in interval {
            let nb = lpowers2[i]
            let db = lpowers2buff[i]
            let sd = lpowers2sbuff[i]
            XCTAssertEqual(nb, db)
            XCTAssertEqual(nb, sd)
            // print(i, nb, db, sd)
        }
        var l1 = lpowers2sbuff
        var l2 = lpowers2buff
        XCTAssert(l1.bufferCount > 10)
        XCTAssert(l2.bufferCount > 10)
        l1.reduceBufferSize(to: 9)
        l2.reduceBufferSize(to: 9)
        XCTAssertEqual(l1.bufferCount, 9)
        XCTAssertEqual(l2.bufferCount, 9)
        l1.reduceBufferSize(to: 0)
        l2.reduceBufferSize(to: 0)
        XCTAssertEqual(l1.bufferCount, 1)
        XCTAssertEqual(l2.bufferCount, 1)
    }

}
