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
		
		let time = measureTime {
			for i in 0..<20 {
				graph[i, i + 1] = 1
				graph[i + 1, i] = 1
			}
			
			graph[3,7] = 1
			graph[7,3] = 1
		}
		
		print("Creation:\t", time)
		print(graph)
		let c = graph.convert(to: Graph_Matrix.self) as! Graph_Matrix
		let cc = c.convert(to: G.self) as! G
		XCTAssert(cc == graph)

		dijkstra(graph: graph)
		bfs(graph: graph)
		dfs(graph: graph)
	}
	
	func dfs<G : Graph>(graph: G) {
		var fn : ([Int], [Int]) = ([], [])
		let time = measureTime {
			fn = graph.depthFirstSearch(start: 0, order: { $0.end < $1.end }, onEntry: { $0 }, onFinish: { $0 })
		}
		print("DFS:\t\t", time, "\t", fn)
	}
	
	func bfs<G : Graph>(graph: G) {
		var fn : [Int] = []
		let time = measureTime {
			fn = graph.breadthFirstSearch(start: 0) { $0 }
		}
		print("BFS:\t\t", time, "\t", fn)
	}
	
	func dijkstra<G : Graph>(graph: G) {
		var path = [0]
		
		let time = measureTime {
			path = graph.djikstra(start: 0, end: 9)
		}
		
		XCTAssert(path == [0, 1, 2, 3, 7, 8, 9])
		
		print("Dijkstra:\t", time, "\t", path)
	}
}

func measureTime(_ f: () -> ()) -> Double {
	let start	= NSDate().timeIntervalSinceReferenceDate
	f()
	let end		= NSDate().timeIntervalSinceReferenceDate
	return end - start
}
