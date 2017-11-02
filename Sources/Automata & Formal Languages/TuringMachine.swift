//
//  TuringMachine.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 08.08.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

struct TuringBand <Character> {
    private var elements: [Character]
    private var index: Int
    
    var currentElement: Character {
        return elements[index]
    }
    
    mutating func advance(by advancing: Int = 1) {
        index += advancing
    }
}

struct TuringMachine <Character> {
    var bands: [TuringBand<Character>]
}
