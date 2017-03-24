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
		
		var time = measureTime {
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
        
		time += bfs(graph: graph)
		time += dfs(graph: graph)
        #if !os(Linux)
        time += heldKarp(graph: G.self)
        #endif
		time += nearestNeighbor(graph: G.self)
        time += pathfinding(graph: G.self)
		time += kruskal(graph: G.self)
		time += hierholzer(graph: G.self)
        time += eulerian(graph: G.self)
		
		// print(graph)
		
		XCTAssert(graph[1,4] == nil)
		XCTAssert(graph[1,2] == 2)
		XCTAssert(graph[3,7] == 1)
		XCTAssert(graph[2,5] == nil)
		print("-----------------------------------------")
		print("TOTAL TIME:\t\t", time, "\n")
        print("\(G.self)", MemoryLayout.stride(ofValue: graph))
		
	}
	
	func dfs(graph: Graph) -> Double {
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
        return time + time2
	}
	
	func bfs(graph: Graph) -> Double {
		var fn : [Int] = []
		let time = measureTime {
			fn = graph.breadthFirstSearch(start: 0) { $0 }
		}
		XCTAssert(fn == [0, 1, 2, 3, 4, 7, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "\(fn)")
		print("BFS:\t\t\t\t", time)
        return time
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
    
    func pathfinding<G : Graph>(graph: G.Type) -> Double {
        
        let matrix = [[false, false, false, false, false, false, false, false, false, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true, false,  true,  true, false],
                      [false,  true, false,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true, false,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true, false,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true, false,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true, false,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true, false,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false,  true,  true,  true,  true,  true,  true,  true,  true, false],
                      [false, false, false, false, false, false, false, false, false, false]
                      ]
        // print(matrix.count, matrix[0].count)
        func id(x: Int, y: Int) -> Int {
            return matrix[0].count * y + x
        }
        
        func reverse(id: Int) -> (x: Int, y: Int) {
            let x = id % matrix[0].count
            let y = id / matrix[0].count
            return (x, y)
        }
        let starttime = Date()
        var g = G()
        
        g.edges = edgeList(ofMap: matrix)
        
        let start = id(x: 3, y: 2)
        let end : Int = id(x: 4, y: 10) // (matrix[0].count * (matrix.count - 1)) - 2
        let endreverse = reverse(id: end)
        
        var path0 = [Int]()
        var path1 = [Int]()
        var path2 = [Int]()
        var path3 = [Int]()

        let heuristic : (Int) -> Int = { (a: Int) -> Int in
            let ra = reverse(id: a)
            let dx = abs(ra.x - endreverse.x)
            let dy = abs(ra.y - endreverse.y)
            return dx + dy
        }
        let time0 = measureTime {
            path0 = g.aStar(start: start, end: end, heuristic: heuristic)!
        }
        let time1 = measureTime {
            path1 = g.bestFirst(start: start, end: end, heuristic: heuristic)!
        }
        let time2 = measureTime {
            path2 = g.djikstra(start: start, end: end)!
        }
        let time3 = measureTime {
            path3 = g.bellmannFord(start: start, end: end)!
        }
        
        func distance(of path: [Int], in graph: G) -> Int {
            guard path.count > 0 else { return 0 }
            var dist = 0
            var prev = path.first!
            for i in path.dropFirst() {
                guard let incDist = graph[prev, i] else { return Int.max }
                dist += incDist
                prev = i
            }
            return dist
        }
        XCTAssert(distance(of: path3, in: g) == distance(of: path2, in: g))
        XCTAssert(distance(of: path0, in: g) == distance(of: path2, in: g))
        XCTAssert(distance(of: path0, in: g) == path0.count - 1)
        XCTAssert(distance(of: path1, in: g) == path1.count - 1)
        XCTAssert(distance(of: path2, in: g) == path2.count - 1)
        XCTAssert(path0 == [23, 22, 21, 31, 41, 42, 52, 62, 72, 82, 92, 93, 94, 104] || path0 == [23, 22, 21, 31, 41, 42, 52, 62, 72, 82, 83, 93, 103, 104], "\(path0)")
        XCTAssert(path2 == [23, 22, 21, 31, 41, 42, 52, 53, 63, 64, 74, 84, 94, 104] || path2 == [23, 22, 21, 31, 41, 42, 52, 53, 63, 73, 83, 93, 103, 104], "\(path2)")
        XCTAssert(path1 == [23, 24, 34, 44, 45, 55, 56, 66, 67, 77, 78, 88, 98, 97, 96, 95, 94, 104] || path1 == [23, 24, 34, 44, 45, 55, 56, 66, 67, 77, 78, 88, 98, 97, 96, 95, 105, 104], "\(path1)")
        XCTAssert(path3 == [23, 22, 21, 31, 41, 51, 61, 71, 81, 82, 92, 93, 94, 104] || path3 == [23, 22, 21, 31, 41, 42, 52, 53, 63, 64, 74, 84, 94, 104], "\(path3)")
        
        /*
        for p in [("A*", path0), ("BestFirst", path1), ("Djikstra", path2), ("BellmannFord", path3)] {
            print("\(p.0):")
            let pathCoordinates = p.1.map { reverse(id: $0) }
            var map = matrix.map { a in a.map { $0 ? " " : "█" } }
            for c in pathCoordinates { map[c.1][c.0] = "X" }
            for m in map { print(m.reduce("", { $0 + $1 })) }
        }
        */
        
        
        let total = -starttime.timeIntervalSinceNow
        print("Pathfinding:\t\t", total, "(A*: \(time0), BestFirst: \(time1), Djikstra: \(time2), BellmannFord: \(time3))")
        return total
    }
	
	func hierholzer< G : Graph >(graph: G.Type) -> Double {
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
        //print("G0")
		let hh0 = g0.hierholzer()
		XCTAssert(hh0 != nil && (hh0! == [4, 5, 3, 0, 1, 2, 3, 4] || hh0! == [5, 3, 0, 1, 2, 3, 4, 5]), "\(hh0)")
        /*
         
         g1:
         
         0 -- 3 --- 5
         |    |\   /
         |    | \ /
         1 -- 2  4
         
         */
        
        //print("G1")
		let hh = g1.hierholzer()
		XCTAssert(hh != nil && (hh! == [4, 5, 3, 2, 1, 0, 3, 4] || hh! == [5, 4, 3, 0, 1, 2, 3, 5]), "\(hh)")

        /*
         
         g2:
         
         0 -- 3 <-- 5
         |    |\   /
         |    | \ /
         1 -- 2  4
         
         */
        
        //print("G2")
        let hh2 = g2.hierholzer()
		XCTAssert(hh2 != nil && (hh2! == [5, 3, 2, 1, 0, 3, 4, 5] || hh2! == [3, 4, 5, 3, 2, 1, 0, 3] || hh2! == [4, 5, 3, 2, 1, 0, 3, 4]), "\(hh2)")

        /*
         
         g3:
         
         1 -- 2  5
         |    | /
         |    |/
         0 -- 3 -- 4
         
         */
        
        //print("G3")
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
        
        //print("G4")
        let hh4 = g4.hierholzer()
        XCTAssert(hh4 != nil && (hh4! == [4, 5, 0, 1, 2, 3, 4, 1] || hh4! == [1, 2, 3, 4, 5, 0, 1, 4]), "\(hh4)")
        
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
        
        //print("HOUSE")
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
        
        //print("SANTA")
        let santahh = house.hierholzer()
        // print(santahh ?? [])
        XCTAssert(santahh != nil && (santahh! == [3, 2, 0, 1, 2, 4, 3, 1, 4] || santahh! == [4, 2, 0, 1, 2, 3, 4, 1, 3] || santahh! == [3, 2, 4, 3, 1, 2, 0, 1, 4]), "\(santahh)")
        
		let total = -start.timeIntervalSinceNow
		print("Hierholzer:\t\t", total)
        return total
	}
    
    func heldKarp< G : Graph >(graph: G.Type) -> Double {
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
        let total = -start.timeIntervalSinceNow
        print("bellmanHeldKarp:\t", total)
        return total
    }
	
	func kruskal< G : Graph >(graph: G.Type) -> Double {
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
        let k0 = g0.kruskal() ?? []
		XCTAssert("\(k0)" == "[(2, 1, -3), (0, 1, 1), (0, 2, 4)]", "\(k0)")
		// XCTAssert(g0.kruskal() == nil)
        let k1 = g1.kruskal() ?? []
		XCTAssert("\(k1)" == "[(2, 1, -3), (0, 1, 1), (2, 0, 4)]" || "\(k1)" == "[(1, 2, -3), (0, 1, 1), (0, 2, 4)]", "\(k1)")
		
        let total = -start.timeIntervalSinceNow
		print("Kruskal:\t\t\t", total)
        return total
	}
	
	func nearestNeighbor< G : Graph >(graph: G.Type) -> Double {
		let start = Date()
		var g = G()
		for i in 0..<10 { g[i, i + 1] = 1 }
		g[5, 7] = -20
		XCTAssert(g.nearestNeighbor(start: 0) == nil)
		g[10, 6] = 1
        XCTAssert(g.nearestNeighbor(start: 0) == nil)
        let total = -start.timeIntervalSinceNow
		print("NearestNeighbor:\t", total)
        return total
	}
    
    func eulerian< G : Graph >(graph: G.Type) -> Double {
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
        let total = -start.timeIntervalSinceNow
        print("Eulerian:\t\t", total)
        return total
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
