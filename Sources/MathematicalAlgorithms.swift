//
//  MathematicalAlgorithms.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 21.11.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public func fibonacci_rec(_ num: Int) -> Int {
    guard num >= 2 else {
        guard num == 1 else { return 0 }
        return 1
    }
    return fibonacci_rec(num - 1) + fibonacci_rec(num - 2)
}

public func fibonacci_ite(_ num: Int) -> Int {
    guard num >= 2 else {
        guard num == 1 else { return 0 }
        return 1
    }
    
    var x = 0
    var y = 1
    var z = 1
    
    for _ in 0..<(num - 1) {
        z = x + y
        x = y
        y = z
    }
    return z
}

public func fibonacci_ite_optimized(_ num: Int) -> Int {
    guard num > 2 else {
        guard num <= 0 else { return 1 }
        return 0
    }

    var x = 0
    var y = 1
    var z = 1
    
    for _ in 0..<((num - 3) / 3) {
        x = y + z
        y = z + x
        z = x + y
    }
        
    for _ in 0...(num % 3) {
        x = y
        y = z
        z = x + y
    }
    
    return z
}





