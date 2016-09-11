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
	
	func testGraph_Types() {
		print()
		graphTest(Graph_Hashing			.self)
		graphTest(Graph_Matrix			.self)
		graphTest(Graph_List			.self)
		graphTest(Graph_AdjacencyList	.self)
	}
	
	func graphTest< G : Graph >(_ graphType: G.Type) {
		print(Banner("\(G.self)"), "\n")
		var graph = graphType.init()
		
		let time = measureTime {
			for i in 0..<20 {
				graph[i, i + 1] = 1
				graph[i + 1, i] = 1
			}
			
			graph[3,7] = 325989328
			graph[3,7] = 1
			graph[7,3] = 1
		}
		
		print("Creation:\t", time)
		
		let graph2 = G.init(vertices: Set<Int>(0...20), rule: { return abs($0 - $1) == 1 ? 1 : (($0, $1) == (3,7) || ($0, $1) == (7,3) ? 1 : nil) })
		
		XCTAssert(graph2 == graph, "\(graph2) != \(graph)")
		
		XCTAssert(graph.vertices == Set<Int>(0...20))
		
		let c = graph.convert(to: Graph_Matrix.self)
		let cc = c.convert(to: G.self)
		XCTAssert(cc == graph, "\(cc) != \(graph)")
				
		dijkstra(graph: graph)
		bfs(graph: graph)
		dfs(graph: graph)
		print(MemoryLayout.stride(ofValue: graph))
		print()
	}
	
	func dfs(graph: Graph) {
		var fn : ([Int], [Int]) = ([], [])
		let time = measureTime {
			fn = graph.depthFirstSearch(start: 0, order: { $0.end < $1.end }, onEntry: { $0 }, onFinish: { $0 })
		}
		XCTAssert(fn.0 == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "\(fn)")
		XCTAssert(fn.1 == [20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], "\(fn)")
		print("DFS:\t\t", time)
	}
	
	func bfs(graph: Graph) {
		var fn : [Int] = []
		let time = measureTime {
			fn = graph.breadthFirstSearch(start: 0) { $0 }
		}
		XCTAssert(fn == [0, 1, 2, 3, 4, 7, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "\(fn)")
		print("BFS:\t\t", time)
	}
	
	func dijkstra(graph: Graph) {
		var path = [0]
		
		let time = measureTime {
			path = graph.djikstra(start: 0, end: 9)
		}
		
		XCTAssert(path == [0, 1, 2, 3, 7, 8, 9], "\(path)")
		
		print("Dijkstra:\t", time)
	}
}

func measureTime(_ f: () throws -> ()) rethrows -> Double {
	let start	= NSDate().timeIntervalSinceReferenceDate
	try f()
	let end		= NSDate().timeIntervalSinceReferenceDate
	return end - start
}

func Banner(_ string: String, count c: Int = 40) -> String {
	guard string.characters.count < c else { return string }
	var result = " \(string) "
	while result.characters.count < c {
		result = "-\(result)-"
	}
	guard result.characters.count == c else { return String(result.characters.dropFirst()) }
	return result
}
