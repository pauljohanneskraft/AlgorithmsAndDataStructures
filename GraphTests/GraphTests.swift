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
	
	func testGraph_Hashing() {
		graphTest(graph: Graph_Hashing())
	}
	
	func testGraph_Matrix() {
		graphTest(graph: Graph_Matrix())
	}
	
	func testGraph_List() {
		graphTest(graph: Graph_List())
	}
	
	func testGraph_AdjacencyList() {
		graphTest(graph: Graph_AdjacencyList())
	}
	
	func graphTest<G : Graph>(graph: G) {
		var graph = graph
		
		let start = NSDate().timeIntervalSinceReferenceDate
		for i in 0..<20 {
			graph[i, i + 1] = 1
			graph[i + 1, i] = 1
		}
		
		graph[3,7] = 1
		graph[7,3] = 1
		
		let end = NSDate().timeIntervalSinceReferenceDate
		
		// print(graph)
		
		let start1 = NSDate().timeIntervalSinceReferenceDate
		let path = graph.djikstra(start: 0, end: 9)
		let end1 = NSDate().timeIntervalSinceReferenceDate
		
		XCTAssert(path == [0, 1, 2, 3, 7, 8, 9])
		
		print("Creation:\t", end - start)
		print("Dijkstra:\t", end1 - start1)
	}
	
}
