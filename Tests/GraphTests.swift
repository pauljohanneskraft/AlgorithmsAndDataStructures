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
				graph[i, i + 1] = 2
				graph[i + 1, i] = 2
			}
			
			graph[3,7] = 325989328
			graph[3,7] = 1
			graph[7,3] = 1
		}
		
		print(graph)
		
		print("Creation:\t\t", time)
		
		let graph2 = G.init(vertices: Set<Int>(0...20), rule: { return abs($0 - $1) == 1 ? 2 : (($0, $1) == (3,7) || ($0, $1) == (7,3) ? 1 : nil) })
		
		XCTAssert(graph2 == graph, "\(graph2) != \(graph)")
		
		XCTAssert(graph.vertices == Set<Int>(0...20))
		
		let c = graph.convert(to: Graph_Matrix.self)
		let cc = c.convert(to: G.self)
		XCTAssert(cc == graph, "\(cc) != \(graph)")
				
		bfs(graph: graph)
		dfs(graph: graph)
		bellmanFord(graph: G.self)
        #if !os(Linux)
        heldKarp(graph: G.self)
        #endif
		nearestNeighbor(graph: G.self)
        pathfinding(graph: G.self)
		kruskal(graph: G.self)
		hierholzer(graph: G.self)
        eulerian(graph: G.self)
		
		// print(graph)
		
		XCTAssert(graph[1,4] == nil)
		XCTAssert(graph[1,2] == 2)
		XCTAssert(graph[3,7] == 1)
		XCTAssert(graph[2,5] == nil)
		
		print("\(G.self)", MemoryLayout.stride(ofValue: graph))
		print()
		
	}
	
	func dfs(graph: Graph) {
		var fn : ([Int], [Int]) = ([], [])
		let time = measureTime {
			fn = graph.depthFirstSearch(start: 0, order: { $0.end < $1.end }, onEntry: { $0 }, onFinish: { $0 })
		}
		XCTAssert(fn.0 == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "\(fn)")
		XCTAssert(fn.1 == [20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], "\(fn)")
        let time2 = measureTime {
            fn = graph.depthFirstSearch(start: 0, order: { $0.end < $1.end }, onEntry: { $0 }, onFinish: { $0 })
        }
        XCTAssert(fn.0 == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "\(fn)")
        XCTAssert(fn.1 == [20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], "\(fn)")
		print("DFS:\t\t\t\t", time + time2)
	}
	
	func bfs(graph: Graph) {
		var fn : [Int] = []
		let time = measureTime {
			fn = graph.breadthFirstSearch(start: 0) { $0 }
		}
		XCTAssert(fn == [0, 1, 2, 3, 4, 7, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "\(fn)")
		print("BFS:\t\t\t\t", time)
	}
    
    func edgeList(ofMap map: [[Bool]]) -> [(start: Int, end: Int, weight: Int)] {
        guard map.count > 0 else { return [] }
        let width = map[0].count
        let height = map.count
        
        func identifier(i: Int, j: Int) -> Int {
            return i * width + j
        }
        
        var edges = [(start: Int, end: Int, weight: Int)]()
        for i in map.indices {
            for j in map[i].indices {
                if let up = i > 0 ? map[i - 1][j] : nil, up == true {
                    edges.append((start: identifier(i: i, j: j), end: identifier(i: i - 1, j: j), weight: 1))
                }
                if let left = j > 0 ? map[i][j - 1] : nil, left == true {
                    edges.append((start: identifier(i: i, j: j), end: identifier(i: i, j: j - 1), weight: 1))
                }
                if let right = j < map[i].count - 1 ? map[i][j + 1] : nil, right == true {
                    edges.append((start: identifier(i: i, j: j), end: identifier(i: i, j: j + 1), weight: 1))
                }
                if let down = i < map.count - 1 ? map[i + 1][j] : nil, down == true {
                    edges.append((start: identifier(i: i, j: j), end: identifier(i: i + 1, j: j), weight: 1))
                }
            }
        }
        return edges
    }
    
    func pathfinding<G : Graph>(graph: G.Type) {
        
        let matrix = [[false, false, false, false, false, false, false, false, false, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true, false, false, false, false, false, false, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false, false, false, false, false, false, false, false, false, false]
                      ]
        
        func id(x: Int, y: Int) -> Int {
            return matrix[0].count * x + y
        }
        
        func reverse(id: Int) -> (x: Int, y: Int) {
            let x = id % matrix[0].count
            let y = id / matrix[0].count
            return (x, y)
        }
        let starttime = Date()
        var g = G()
        
        g.edges = edgeList(ofMap: matrix)
        
        let end : Int = (matrix[0].count * (matrix.count - 1)) - 2
        let endreverse = reverse(id: end)
        
        var path0 = [Int]()
        var path1 = [Int]()
        var path2 = [Int]()

        let heuristic : (Int) -> Int = { (a: Int) -> Int in
            let ra = reverse(id: a)
            let dx = ra.x - endreverse.x
            let dy = ra.y - endreverse.y
            return dx * dx + dy * dy
        }
        let start = id(x: 1, y: 1)
        let time0 = measureTime {
            path0 = g.aStar(start: start, end: end, heuristic: heuristic)!
        }
        let time1 = measureTime {
            path1 = g.bestFirst(start: start, end: end, heuristic: heuristic)!
        }
        let time2 = measureTime {
            path2 = g.djikstra(start: start, end: end)
        }
        
        func distance(of path: [Int], in graph: G) -> Int {
            guard path.count > 0 else { return 0 }
            var dist = 0
            var prev = path.first!
            for i in path.dropFirst() {
                dist += graph[prev, i]!
                prev = i
            }
            return dist
        }
        XCTAssert(distance(of: path0, in: g) == distance(of: path2, in: g))
        XCTAssert(distance(of: path0, in: g) == path0.count - 1)
        XCTAssert(distance(of: path1, in: g) == path1.count - 1)
        XCTAssert(distance(of: path2, in: g) == path2.count - 1)
        XCTAssert(path0 == [11, 21, 31, 32, 42, 52, 62, 72, 82, 92, 102, 103, 104, 105, 106, 107, 108], "\(path0)")
        XCTAssert(path2 == [11, 12, 22, 32, 42, 52, 62, 72, 82, 92, 102, 103, 104, 105, 106, 107, 108], "\(path2)")
        XCTAssert(path1 == [11, 21, 31, 32, 42, 52, 53, 63, 64, 65, 75, 85, 84, 83, 82, 92, 102, 103, 104, 105, 106, 107, 108], "\(path1)")
        /*
        for p in [path0, path1, path2] {
            let pathCoordinates = p.map { reverse(id: $0) }
            var map = matrix.map { a in a.map { $0 ? " " : "█" } }
            for c in pathCoordinates { map[c.1][c.0] = "X" }
            for m in map { print(m.reduce("", { $0 + $1 })) }
        }
        */
        print("Pathfinding:\t\t", -starttime.timeIntervalSinceNow, "(A*: \(time0), BestFirst: \(time1), Djikstra: \(time2))")
    }
	
	func hierholzer< G : Graph >(graph: G.Type) {
		/*
		
		0 <- 3 <-- 5
		|    ^\   ^
        °    | ° /
		1 -> 2  4
		
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
		let start = Date()
        
        /*
         
         g0:
         
         0 <- 3 <-- 5
         |    ^\   ^
         °    | ° /
         1 -> 2  4
         
         °, ^, >, < is always the end of an arrow
         
         */
        
		let hh0 = g0.hierholzer()
		XCTAssert(hh0 != nil && (hh0! == [4, 5, 3, 0, 1, 2, 3, 4] || hh0! == [5, 3, 0, 1, 2, 3, 4, 5]), "\(hh0)")
        /*
         
         g1:
         
         0 -- 3 --- 5
         |    |\   /
         |    | \ /
         1 -- 2  4
         
         */
        
		let hh = g1.hierholzer()!
		XCTAssert(hh == [4, 5, 3, 2, 1, 0, 3, 4] || hh == [5, 4, 3, 0, 1, 2, 3, 5], "\(hh)")

        /*
         
         g2:
         
         0 -- 3 <-- 5
         |    |\   /
         |    | \ /
         1 -- 2  4
         
         */
        
        let hh2 = g2.hierholzer()
		XCTAssert(hh2 != nil && (hh2! == [5, 3, 2, 1, 0, 3, 4, 5] || hh2! == [3, 4, 5, 3, 2, 1, 0, 3] || hh2! == [4, 5, 3, 2, 1, 0, 3, 4]), "\(hh2)")

        /*
         
         g3:
         
         1 -- 2  5
         |    | /
         |    |/
         0 -- 3 -- 4
         
         */
        
        let hh3 = g3.hierholzer()
		XCTAssert(hh3 != nil && (hh3! == [5, 3, 2, 1, 0, 3, 4]), "\(hh3)")
        
        var g4 = G()
        
        g4[0, 1] = 1
        g4[0, 5] = 1
        g4[1, 0] = 1
        g4[1, 4] = 1
        g4[1, 2] = 1
        g4[2, 1] = 1
        g4[2, 3] = 1
        g4[3, 2] = 1
        g4[3, 4] = 1
        g4[4, 1] = 1
        g4[4, 3] = 1
        g4[4, 5] = 1
        g4[5, 0] = 1
        g4[5, 4] = 1
        
        XCTAssert(g4.semiEulerian)
        XCTAssert(g4.unEvenVertices(directed: false)! == 2)
        
        /*
         
         5 -- 4 -- 3
         |    |    |
         |    |    |
         0 -- 1 -- 2
         
         */
        
        let hh4 = g4.hierholzer()!
        XCTAssert(hh4 == [4, 5, 0, 1, 2, 3, 4, 1] || hh4 == [1, 2, 3, 4, 5, 0, 1, 4], "\(hh4)")
        
        /*
            0
           / \
          /   \
         1 --- 2
         |     |
         |     |
         3 --- 4
         
        */
        
        var house = G()
        
        house[0, 1] = 1
        house[1, 0] = 1
        
        house[0, 2] = 1
        house[2, 0] = 1
        
        house[2, 1] = 1
        house[1, 2] = 1
        
        house[3, 1] = 1
        house[1, 3] = 1
        
        house[2, 4] = 1
        house[4, 2] = 1
        
        house[3, 4] = 1
        house[4, 3] = 1
        
        let househh = house.hierholzer()
        // print(househh ?? [])
        XCTAssert(househh != nil && (househh! == [2, 0, 1, 2, 4, 3, 1]), "\(househh)")
        
        house[3, 2] = 1
        house[2, 3] = 1
        
        house[1, 4] = 1
        house[4, 1] = 1
        
        /*
            0
           / \
          /   \
         1 --- 2
         | \ / |
         | / \ |
         3 --- 4
         
         */
        
        let santahh = house.hierholzer()
        // print(santahh ?? [])
        XCTAssert(santahh != nil && (santahh! == [3, 2, 0, 1, 2, 4, 3, 1, 4] || santahh! == [4, 2, 0, 1, 2, 3, 4, 1, 3] || santahh! == [3, 2, 4, 3, 1, 2, 0, 1, 4]), "\(santahh)")
        
		
		print("Hierholzer:\t\t", -start.timeIntervalSinceNow)
	}
    
    func heldKarp< G : Graph >(graph: G.Type) {
        // var g0 = Graph_Hashing()
        
        // let m = [[nil, 10, 15, 20], [5, nil, 9, 10], [6, 13, nil, 12], [8, 8, 9, nil]]
        
        // let g1 = Graph_Matrix(m)
        
        // print(g1.bellmanHeldKarp(start: 0)!)
        /*
        g0[0, 1] = 1
        g0[0, 2] = 4
        g0[1, 2] = 1
        g0[2, 0] = 3
        g0[2, 1] = 2
        g0[0, 0] = 1
        
        print("done with init")
        
        print(g0.bellmanHeldKarp(start: 0)!)
 */
        let start = Date()
        let matrix = [
            [0, 23, 46, 68, 52, 72, 42],
            [29, 0, 23, 42, 43, 43, 23],
            [82, 55, 0, 23, 55, 23, 43],
            [46, 46, 68, 0, 15, 72, 31],
            [68, 42, 46, 82, 0, 23, 52],
            [52, 43, 55, 15, 74, 0, 23],
            [450, 43, 23, 72, 23, 61, 0],
        ]
        let g = Graph_Matrix(matrix).convert(to: G.self)
        let res = g.bellmanHeldKarp(start: 0)!
        // print(res)
        XCTAssert(res.0 == [0, 1, 6, 2, 3, 4, 5, 0])
        XCTAssert(res.1 == 182)
        print("bellmanHeldKarp:\t", -start.timeIntervalSinceNow)
    }
	
	func kruskal< G : Graph >(graph: G.Type) {
		var g0 = G()
		
		g0[0, 1] = 1
		g0[0, 2] = 4
		g0[1, 2] = 1
		g0[2, 1] = -3
		
		
		var g1 = G()
		
		g1[0, 1] = 1
		g1[1, 0] = 1
		g1[0, 2] = 4
		g1[2, 0] = 4
		g1[1, 2] = -3
		g1[2, 1] = -3
		
		let start = Date()
		
		XCTAssert(g0.kruskal() == nil)
		_ = g1.kruskal()!
		
		print("Kruskal:\t\t\t", -start.timeIntervalSinceNow)
	}
	
	func nearestNeighbor< G : Graph >(graph: G.Type) {
		let start = Date()
		var g = G()
		for i in 0..<10 { g[i, i + 1] = 1 }
		g[5, 7] = -20
		XCTAssert(g.nearestNeighbor(start: 0) == nil)
		g[10, 6] = 1
        XCTAssert(g.nearestNeighbor(start: 0) == nil)
		print("NearestNeighbor:\t", -start.timeIntervalSinceNow)
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
		print("BellmanFord:\t\t", time)
	}
    
    func eulerian< G : Graph >(graph: G.Type) {
        let start = Date()
        var g = G()
        g[0, 1] = 1
        g[0, 2] = 4
        g[1, 2] = 1
        g[2, 1] = -3
        XCTAssert(g.directed == true)
        XCTAssert(g.unEvenVertices(directed: g.directed) == nil)
        XCTAssert(g.semiEulerian == false)
        XCTAssert(g.eulerian == false)
        g[1, 0] = 2
        XCTAssert(g.directed == true)
        XCTAssert(g.unEvenVertices(directed: g.directed)! == 2)
        XCTAssert(g.semiEulerian == true)
        XCTAssert(g.eulerian == false)
        g[2, 0] = 10
        XCTAssert(g.directed == false)
        XCTAssert(g.unEvenVertices(directed: g.directed)! == 0)
        XCTAssert(g.semiEulerian == true)
        XCTAssert(g.eulerian == true)
        print("Eulerian:\t\t", -start.timeIntervalSinceNow)
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
