//
//  MathTests.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 21.11.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import XCTest
import Algorithms_and_Data_structures

class MathTests: XCTestCase {

    func testFibonacci() {
        
        print(fibonacci_ite_optimized(55))
        for _ in 0..<1 {
            var u = [Int]()
            var o = [Int]()
            let ind = [Int](70...80)
            
            let m1 = Date()
            for _ in 0..<Int8.max { u = ind.map { fibonacci_ite($0) } }
            let m2 = Date()
            for _ in 0..<Int8.max { o = ind.map { fibonacci_ite_optimized($0) } }
            let m3 = Date()
            
            let t_ite   = m2.timeIntervalSince(m1)
            let t_iteo  = m3.timeIntervalSince(m2)
            
            print("result: ran for", t_ite, " or ", t_iteo, "seconds.")
            
            guard u == o else {
                print("didn't match:", u, o)
                return
            }

        }
    }

}
