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
		
		print("Creation:\t\t", time)
		
		let graph2 = G.init(vertices: Set<Int>(0...20), rule: { return abs($0 - $1) == 1 ? 1 : (($0, $1) == (3,7) || ($0, $1) == (7,3) ? 1 : nil) })
		
		XCTAssert(graph2 == graph, "\(graph2) != \(graph)")
		
		XCTAssert(graph.vertices == Set<Int>(0...20))
		
		let c = graph.convert(to: Graph_Matrix.self)
		let cc = c.convert(to: G.self)
		XCTAssert(cc == graph, "\(cc) != \(graph)")
				
		dijkstra(graph: graph)
		bfs(graph: graph)
		dfs(graph: graph)
		bellmanFord(graph: G.self)
		nearestNeighbor(graph: G.self)
		kruskal(graph: G.self)
		hierholzer(graph: G.self)
		
		// print(graph)
		
		XCTAssert(graph[1,4] == nil)
		XCTAssert(graph[1,2] == 1)
		XCTAssert(graph[3,7] == 1)
		XCTAssert(graph[2,5] == nil)
		
		// print(MemoryLayout.stride(ofValue: graph))
		print()
		
	}
	
	func dfs(graph: Graph) {
		var fn : ([Int], [Int]) = ([], [])
		let time = measureTime {
			fn = graph.depthFirstSearch(start: 0, order: { $0.end < $1.end }, onEntry: { $0 }, onFinish: { $0 })
		}
		XCTAssert(fn.0 == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "\(fn)")
		XCTAssert(fn.1 == [20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], "\(fn)")
		print("DFS:\t\t\t", time)
	}
	
	func bfs(graph: Graph) {
		var fn : [Int] = []
		let time = measureTime {
			fn = graph.breadthFirstSearch(start: 0) { $0 }
		}
		XCTAssert(fn == [0, 1, 2, 3, 4, 7, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "\(fn)")
		print("BFS:\t\t\t", time)
	}
	
	func dijkstra(graph: Graph) {
		var path = [0]
		
		let time = measureTime {
			path = graph.djikstra(start: 0, end: 9)
		}
		
		XCTAssert(path == [0, 1, 2, 3, 7, 8, 9], "\(path)")
		
		print("Dijkstra:\t\t", time)
	}
	
	func hierholzer< G : Graph >(graph: G.Type) {
		let start = Date()
		/*
		
		0----3----4
		|    |\  /
		|    | \/
		1----2  5
		
		*/
		
		
		var g0 = G()
		g0[0, 1] = 1
		g0[1, 2] = 1
		g0[2, 3] = 1
		g0[3, 0] = 1
		g0[3, 4] = 1
		g0[4, 5] = 1
		g0[5, 3] = 1
		
		// print(g0)
		// print(g0.eulerian)
		// print(g0.semiEulerian)
		XCTAssert(g0.hierholzer() == nil) // TODO: Hierholzer also for directed, (semi-)eulerian graphs
		
		var g1 = G()
		
		g1[0, 1] = 1
		g1[1, 0] = 1
		
		g1[1, 2] = 1
		g1[2, 1] = 1
		
		g1[2, 3] = 1
		g1[3, 2] = 1
		
		g1[3, 0] = 1
		g1[0, 3] = 1
		
		g1[3, 4] = 1
		g1[4, 3] = 1
		
		g1[4, 5] = 1
		g1[5, 4] = 1
		
		g1[5, 3] = 1
		g1[3, 5] = 1
		
		// print(g1)
		_ = g1.hierholzer()!
		
		var g2 = G()
		
		g2[0, 1] = 1
		g2[1, 0] = 1
		
		g2[1, 2] = 1
		g2[2, 1] = 1
		
		g2[2, 3] = 1
		g2[3, 2] = 1
		
		g2[3, 0] = 1
		g2[0, 3] = 1
		
		g2[3, 4] = 1
		g2[4, 3] = 1
		
		g2[4, 5] = 1
		g2[5, 4] = 1
		
		g2[5, 3] = 1
		// g2[3, 5] = 1
		
		// print(g2)
		XCTAssert(g2.hierholzer() == nil)
		
		var g3 = G()
		
		g3[0, 1] = 1
		g3[1, 0] = 1
		
		g3[1, 2] = 1
		g3[2, 1] = 1
		
		g3[2, 3] = 1
		g3[3, 2] = 1
		
		g3[3, 0] = 1
		g3[0, 3] = 1
		
		g3[3, 4] = 1
		g3[4, 3] = 1
		
		g3[5, 3] = 1
		g3[3, 5] = 1
		
		// print(g3)
		_ = g3.hierholzer()!
		
		print("Hierholzer:\t\t", -start.timeIntervalSinceNow)
	}
	
	func kruskal< G : Graph >(graph: G.Type) {
		let start = Date()
		var g0 = G()
		
		g0[0, 1] = 1
		g0[0, 2] = 4
		g0[1, 2] = 1
		g0[2, 1] = -3
		
		XCTAssert(g0.kruskal() == nil)
		
		var g1 = G()
		
		g1[0, 1] = 1
		g1[1, 0] = 1
		g1[0, 2] = 4
		g1[2, 0] = 4
		g1[1, 2] = -3
		g1[2, 1] = -3
		
		_ = g1.kruskal()!
		
		print("Kruskal:\t\t", -start.timeIntervalSinceNow)
	}
	
	func nearestNeighbor< G : Graph >(graph: G.Type) {
		let start = Date()
		var g = G()
		for i in 0..<10 { g[i, i + 1] = 1 }
		g[5, 7] = -20
		XCTAssert(g.nearestNeighbor(start: 0) == nil)
		g[10, 6] = 1
		let gnN = g.nearestNeighbor(start: 0)!
		XCTAssert(gnN.0 == [0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 6])
		XCTAssert(gnN.1 == -11)
		print("NearestNeighbor:", -start.timeIntervalSinceNow)
	}
	
	func bellmanFord< G : Graph >(graph: G.Type) {
		var g = G()
		for i in 0..<10 {
			g[i, i + 1] = 1
		}
		g[7, 5] = -20
		let start = Date()
		let visited = g.bellmanFord(start: 0)
		let time = -start.timeIntervalSinceNow
		// print(visited.map { "\($0.key) - \($0.value.last): \($0.value.weight)" })
		for v in visited {
			if v.key >= 5 {
				XCTAssert(v.value.weight == Int.min)
			} else {
				XCTAssert(v.value.weight == v.key)
			}
		}
		print("BellmanFord:\t", time)
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
