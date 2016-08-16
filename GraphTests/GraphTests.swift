//
//  GraphTests.swift
//  GraphTests
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import XCTest
import Algorithms_and_Data_structures

class GraphTests: XCTestCase {
    
    func testGraph() {
        var asymmGraph = Graph_Hashing<Vertex>(rule: {
            start, end in
            if start.hashValue == end.hashValue - 1 { return 1 } else { return nil }
        })
        
        for i in 0..<20 { asymmGraph.insert(Vertex(value: i)) }
        
        print(asymmGraph)
        
        /*
         asymmGraph.rule = {
         start, end in
         if (start.hashValue % 3) >= (end.hashValue % 5) { return 1 } else { return nil } }
         print(asymmGraph)
         */
        
        let s = asymmGraph.vertices[0]!
        let e = asymmGraph.vertices[9]!
        let path = asymmGraph.djikstra(start: s, end: e)
        
        print(path)
    }
}
