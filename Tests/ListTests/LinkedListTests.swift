//
//  DoublyLinkedListTests.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 01.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

class LinkedListTests: XCTestCase {

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
    
    var arrs = [[Int]]()
    
    func testSingly() {
        insertAndRemove(using: SinglyLinkedList<Int>.self)
    }
    
    func testDoubly() {
        insertAndRemove(using: DoublyLinkedList<Int>.self)
    }
    
    func insertAndRemove<L: List>(using type: L.Type) where L.Element == Int {
        for arr in arrs {
            var ll = L.init()
            
            for i in arr.indices {
                XCTAssertNotNil(try? ll.insert(arr[i], at: i))
            }
            
            do {
                try ll.insert(arr[0], at: arr.count + 1)
                XCTAssert(false)
            } catch let e as ListError {
                XCTAssertEqual(e, ListError.indexOutOfRange)
            } catch {
                XCTFail("Wrong Error thrown.")
            }
            
            XCTAssertEqual(ll.count, arr.count)
            XCTAssertEqual(ll.array, arr)
            
            for i in arr.indices {
                XCTAssertEqual(arr[i], ll[i])
                ll[i] = arr[i]
            }
            
            XCTAssertEqual(ll.array, arr)
            
            var llRev = [Int]()
            
            for i in arr.indices.reversed() {
                guard let b = try? ll.remove(at: i) else {
                    XCTFail("remove(at:) returned nil")
                    continue
                }
                llRev.append(b)
            }
            
            XCTAssertEqual(ll.count, 0)
            
            let arrRev: [Int] = arr.reversed()
            XCTAssertEqual(llRev, arrRev)
            
            for i in arrRev.indices { ll[i] = arrRev[i] }
            
            XCTAssertEqual(ll.array, arrRev)
            
            var arr2 = [Int]()
            for _ in arrRev.indices { arr2.append(ll.popBack()!) }
            
            XCTAssertEqual(arr2, arr)
            XCTAssertEqual(ll.count, 0)
            
            for e in arr { ll.pushBack(e) }
            
            XCTAssertEqual(ll.array, arr)
        }
        
        let l = L.init(arrayLiteral: 1, 2, 3)
        if L.self == SinglyLinkedList<Int>.self {
            XCTAssertEqual(l.description, "[1 -> 2 -> 3]")
        } else if L.self == DoublyLinkedList<Int>.self {
            XCTAssertEqual(l.description, "[1 <-> 2 <-> 3]")
        } else { XCTAssert(false, "add this type") }
    }

}
