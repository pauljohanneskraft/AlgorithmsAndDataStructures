//
//  NFATests.swift
//  AutomataTests
//
//  Created by Paul Kraft on 02.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

class NFATests: XCTestCase {
    
    func testPerformanceExample() {
        let nfa = NFA<Character>(states: [
            0: NFAState<Character>(transition: { _ in [1] }),
            1: NFAState<Character>(transition: { _ in []  })
            ], initialStates: [0], finalStates: [0])
        
        XCTAssertEqual(try? nfa.accepts(word: ""  .characters), true )
        XCTAssertEqual(try? nfa.accepts(word: "a" .characters), false)
        XCTAssertEqual(try? nfa.accepts(word: "ab".characters), false)
    }
    
    func testDivisibleBy3() {
        let nfa = NFA<Character>(states: [
            0: NFAState { ["0": [0], "1": [1]][$0] ?? [] },
            1: NFAState { ["0": [2], "1": [0]][$0] ?? [] },
            2: NFAState { ["0": [1], "1": [2]][$0] ?? [] }
            ], initialStates: [0], finalStates: [0])
        
        for _ in 0..<100 {
            let random = Int(arc4random())
            let base2str = random.description(radix: 2)
            let divBy3 = (random % 3 == 0)
            // print("random:", random, "in base 2:", base2str, divBy3)
            XCTAssertEqual(try? nfa.accepts(word: base2str.characters), divBy3)
        }
    }
}
