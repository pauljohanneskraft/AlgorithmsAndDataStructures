//
//  DFATests.swift
//  AutomataTests
//
//  Created by Paul Kraft on 02.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable trailing_whitespace

class DFATests: XCTestCase {
    func testExample1() {
        let dfa = DFA<Character>(states: [
            0: DFA.State(transition: { _ in 1 }),
            1: DFA.State(transition: { _ in 0 })
            ], initialState: 0, finalStates: [0])
        
        XCTAssertEqual(try? dfa.accepts(word: ""  .characters), true )
        XCTAssertEqual(try? dfa.accepts(word: "a" .characters), false)
        XCTAssertEqual(try? dfa.accepts(word: "ab".characters), true )
    }
    
    func testDivisibleBy3() {
        let dfa = DFA<Character>(states: [
            0: DFA.State { ["0": 0, "1": 1][$0] ?? 3 },
            1: DFA.State { ["0": 2, "1": 0][$0] ?? 3 },
            2: DFA.State { ["0": 1, "1": 2][$0] ?? 3 },
            3: DFA.State { _ in 3 }
            ], initialState: 0, finalStates: [0])
        
        for _ in 0..<100 {
            let random = Int(arc4random())
            let base2str = random.description(radix: 2)
            let divBy3 = (random % 3 == 0)
            // print("random:", random, "in base 2:", base2str, divBy3)
            XCTAssertEqual(try? dfa.accepts(word: base2str.characters), divBy3)
        }
    }
}
