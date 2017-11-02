//
//  Gray.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 09.08.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

extension Int {
    public var grayCode: Int {
        return self ^ (self >> 1)
    }
    
    public func hammingDistance(to other: Int) -> Int {
        let ones: [Character] = (self ^ other).description(radix: 2).characters.filter { $0 == "1" }
        return ones.count
    }
    
    public init(grayCode: Int) {
        self = grayCode
        var mask = grayCode >> 1
        while mask != 0 {
            self = self ^ mask
            mask >>= 1
        }
    }
}
