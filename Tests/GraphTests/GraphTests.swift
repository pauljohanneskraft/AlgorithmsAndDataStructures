//
//  GraphTests.swift
//  GraphTests
//
//  Created by Paul Kraft on 02.11.17.
//

import XCTest
@testable import Algorithms_DataStructures

// swiftlint:disable file_length type_body_length trailing_whitespace function_body_length

class GraphTests: XCTestCase {
    
    func testGraph_Types() {
        print()
        var results = [(type: String, result: Double)]()
        results.append(result(HashingGraph      .self))
        results.append(result(MatrixGraph       .self))
        results.append(result(ListGraph         .self))
        results.append(result(AdjacencyListGraph.self))
        
        print(results.min { $0.result < $1.result }!)
    }
    
    func result<G: Graph>(_ graphType: G.Type) -> (String, Double) {
        return ("\(graphType.self)", graphTest(graphType))
    }
    
    func graphTest<G: Graph>(_ graphType: G.Type) -> Double {
        print(banner("\(G.self)"), "\n")
        var graph = graphType.init()
        
        var time = measureTime {
            for i in 0..<20 {
                graph[i, i + 1] = 2
                graph[i + 1, i] = 2
            }
            
            graph[3, 7] = 325989328
            graph[3, 7] = 1
            graph[7, 3] = 1
        }
        
        print(graph)
        
        print("Creation:\t\t", time)
        
        let rule = { (num1: Int, num2: Int) -> Int? in
            if abs(num1 - num2) == 1 {    return 2 }
            switch (num1, num2) {
            case (3, 7), (7, 3):    return 1
            default:                return nil
            }
        }
        
        let graph2 = G.init(vertices: Set<Int>(0...20), rule: rule)
        
        XCTAssert(graph2 == graph)
        
        XCTAssertEqual(graph.vertices, Set<Int>(0...20))
        
        let c = graph.convert(to: MatrixGraph.self)
        let cc = c.convert(to: G.self)
        XCTAssert(cc == graph)
        
        time += bfs(graph: graph)
        time += dfs(graph: graph)
        #if !os(Linux)
            time += heldKarp(graph: G.self)
        #endif
        time += nearestNeighbor(graph: G.self)
        time += pathfinding(graph: G.self)
        // time += kruskal(graph: G.self)
        time += hierholzer(graph: G.self)
        time += eulerian(graph: G.self)
        
        // print(graph)
        
        var gVertices = G()
        
        gVertices[2, 3] = 1
        gVertices[2, 3] = nil
        gVertices[4, 5] = 2
        gVertices[4, 5] = nil
        gVertices[3, 2] = 4
        
        XCTAssertEqual(gVertices.vertices, Set<Int>([2, 3]))
        
        XCTAssertNil(graph[1, 4])
        XCTAssertEqual(graph[1, 2], 2)
        XCTAssertEqual(graph[3, 7], 1)
        XCTAssertNil(graph[2, 5])
        print("-----------------------------------------")
        print("TOTAL TIME:\t\t", time, "\n")
        print("\(G.self)", MemoryLayout.stride(ofValue: graph))
        return time
    }
    
    func dfs(graph: Graph) -> Double {
        var fn: ([Int], [Int]) = ([], [])
        let time = measureTime {
            fn = graph.depthFirstSearch(start: 0, order: { $0.end < $1.end }, onEntry: { $0 }, onFinish: { $0 })
        }
        XCTAssertEqual(fn.0, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
        XCTAssertEqual(fn.1, [20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
        let time2 = measureTime {
            fn = graph.depthFirstSearch(start: 0, order: { $0.end < $1.end }, onEntry: { $0 }, onFinish: { $0 })
        }
        XCTAssertEqual(fn.0, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
        XCTAssertEqual(fn.1, [20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
        print("DFS:\t\t\t\t", time + time2)
        return time + time2
    }
    
    func bfs(graph: Graph) -> Double {
        var fn: [Int] = []
        let time = measureTime {
            fn = graph.breadthFirstSearch(start: 0) { $0 }
        }
        XCTAssertEqual(fn, [0, 1, 2, 3, 4, 7, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
        print("BFS:\t\t\t\t", time)
        return time
    }
    
    func edgeList(ofMap map: [[Bool]]) -> Set<GraphEdge> {
        guard map.count > 0 else { return [] }
        let width = map[0].count
        let height = map.count
        
        // swiftlint:disable:next identifier_name
        func identifier(i: Int, j: Int) -> Int {
            return i * width + j
        }
        
        var edges = Set<GraphEdge>()
        for i in map.indices {
            for j in map[i].indices {
                if i > 0 && map[i - 1][j] == true {
                    let edge = GraphEdge(start: identifier(i: i, j: j), end: identifier(i: i - 1, j: j), weight: 1)
                    edges.insert(edge)
                }
                if j > 0 && map[i][j - 1] == true {
                    let edge = GraphEdge(start: identifier(i: i, j: j), end: identifier(i: i, j: j - 1), weight: 1)
                    edges.insert(edge)
                }
                if j < map[i].count - 1 && map[i][j + 1] == true {
                    let edge = GraphEdge(start: identifier(i: i, j: j), end: identifier(i: i, j: j + 1), weight: 1)
                    edges.insert(edge)
                }
                if i < map.count - 1 && map[i + 1][j] == true {
                    let edge = GraphEdge(start: identifier(i: i, j: j), end: identifier(i: i + 1, j: j), weight: 1)
                    edges.insert(edge)
                }
            }
        }
        return edges
    }
    
    func pathfinding<G: Graph>(graph: G.Type) -> Double {
        
        // swiftlint:disable comma
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
        // swiftlint:enable comma
        
        // swiftlint:disable:next identifier_name
        func id(x: Int, y: Int) -> Int {
            return matrix[0].count * y + x
        }
        
        // swiftlint:disable:next identifier_name
        func reverse(id: Int) -> (x: Int, y: Int) {
            let x = id % matrix[0].count
            let y = id / matrix[0].count
            return (x, y)
        }
        var g = G()
        
        g.edges = edgeList(ofMap: matrix)
        
        let start = id(x: 3, y: 2)
        let end = id(x: 4, y: 10) // (matrix[0].count * (matrix.count - 1)) - 2
        let endreverse = reverse(id: end)
        
        var path0 = [Int]()
        var path1 = [Int]()
        var path2 = [Int]()
        var path3 = [Int]()
        var path4 = [Int]()
        var path5 = [Int]()
        
        let heuristic: (Int) -> Int = {
            let ra = reverse(id: $0)
            let dx = abs(ra.x - endreverse.x)
            let dy = abs(ra.y - endreverse.y)
            return dx + dy
        }
        
        let starttime = Date()
                
        let time0 = measureTime {
            path0 = g.aStar(start: start, end: end, heuristic: heuristic) ?? []
        }
        let time1 = measureTime {
            path1 = g.bestFirst(start: start, end: end, heuristic: heuristic) ?? []
        }
        let time2 = measureTime {
            path2 = g.djikstra(start: start, end: end) ?? []
        }
        let time3 = measureTime {
            path3 = g.bellmannFord(start: start, end: end) ?? []
        }
        let time4 = measureTime {
            path4 = path3 //g.concurrentDijkstra(start: start, end: end) ?? []
        }
        
        let total = -starttime.timeIntervalSinceNow
        
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
        XCTAssertEqual(path3.count, path2.count)
        XCTAssertEqual(path0.count, path2.count)
        XCTAssertEqual(path4.count, path2.count)
        XCTAssertEqual(distance(of: path0, in: g), path0.count - 1)
        XCTAssertEqual(distance(of: path1, in: g), path1.count - 1)
        XCTAssertEqual(distance(of: path2, in: g), path2.count - 1)
        
        func valid(path: [Int]) -> Bool {
            guard path.first == start && path.last == end else { return false }
            guard var current = path.first else { return true }
            for next in path.dropFirst() {
                let diff = abs(next - current)
                guard diff == 1 || diff == matrix[0].count else { return false }
                current = next
            }
            return true
        }
        
        XCTAssert(valid(path: path0), "\(path0)")
        XCTAssert(valid(path: path1), "\(path1)")
        XCTAssert(valid(path: path2), "\(path2)")
        XCTAssert(valid(path: path3), "\(path3)")
        XCTAssert(valid(path: path4), "\(path4)")
        
        let ps = [
            ("A*", path0), ("BestFirst", path1),
            ("Djikstra", path2), ("BellmannFord", path3),
            ("ConcDijkstra", path4), ("ConcA*", path5)
        ]
        for p in ps {
            print("\(p.0):")
            let pathCoordinates = p.1.map { reverse(id: $0) }
            var map = matrix.map { line in line.map { $0 ? " " : "█" } }
            for c in pathCoordinates { map[c.1][c.0] = "X" }
            for m in map { print(m.reduce("", { $0 + $1 })) }
        }
        
        print("Pathfinding:\t\t", total, "(A*: \(time0), BestFirst: \(time1), Djikstra: \(time2),",
            "BellmannFord: \(time3), ConcurrentDijkstra: \(time4))")
        return total
    }
    
    func hierholzer<G: Graph>(graph: G.Type) -> Double {
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
        guard let hh0 = g0.hierholzer() else {
            XCTFail("Hierholzer returned nil.")
            return Double.greatestFiniteMagnitude
        }
        
        XCTAssert(hh0 == [4, 5, 3, 0, 1, 2, 3, 4] || hh0 == [5, 3, 0, 1, 2, 3, 4, 5],
            "\(String(describing: hh0))")
        /*
         
         g1:
         
         0 -- 3 --- 5
         |    |\   /
         |    | \ /
         1 -- 2  4
         
         */
        
        //print("G1")
        guard let hh1 = g1.hierholzer() else {
            XCTFail("Hierholzer returned nil.")
            return Double.greatestFiniteMagnitude
        }
        
        XCTAssert(hh1 == [4, 5, 3, 2, 1, 0, 3, 4] || hh1 == [5, 4, 3, 0, 1, 2, 3, 5]
            || hh1 == [0, 3, 5, 4, 3, 2, 1, 0], "\(String(describing: hh1))")
        
        /*
         
         g2:
         
         0 -- 3 <-- 5
         |    |\   /
         |    | \ /
         1 -- 2  4
         
         */
        
        //print("G2")
        guard let hh2 = g2.hierholzer() else {
            XCTFail("Hierholzer returned nil")
            return Double.greatestFiniteMagnitude
        }
        XCTAssert(
            hh2 == [5, 3, 2, 1, 0, 3, 4, 5] || hh2 == [3, 4, 5, 3, 2, 1, 0, 3] || hh2 == [4, 5, 3, 2, 1, 0, 3, 4],
            "\(String(describing: hh2))")
        
        /*
         
         g3:
         
         1 -- 2  5
         |    | /
         |    |/
         0 -- 3 -- 4
         
         */
        
        //print("G3")
        guard let hh3 = g3.hierholzer() else {
            XCTFail("Hierholzer returned nil")
            return Double.greatestFiniteMagnitude
        }
        XCTAssertEqual(hh3, [5, 3, 2, 1, 0, 3, 4])
        
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
        XCTAssertEqual(g4.unEvenVertices(directed: false)!, 2)
        
        /*
         
         5 -- 4 -- 3
         |    |    |
         |    |    |
         0 -- 1 -- 2
         
         */
        
        //print("G4")
        guard let hh4 = g4.hierholzer() else {
            XCTFail("Hierholzer returned nil")
            return Double.greatestFiniteMagnitude
        }
        XCTAssert(hh4 == [4, 5, 0, 1, 2, 3, 4, 1] || hh4 == [1, 2, 3, 4, 5, 0, 1, 4], "\(String(describing: hh4))")
        
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
        guard let househh = house.hierholzer() else {
            XCTFail("Hierholzer returned nil")
            return Double.greatestFiniteMagnitude
        }
        // print(househh ?? [])
        XCTAssert(househh == [2, 0, 1, 2, 4, 3, 1] || househh == [1, 2, 0, 1, 3, 4, 2],
                  "\(String(describing: househh))")
        
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
        guard let santahh = house.hierholzer() else {
            XCTFail("Hierholzer returned nil")
            return Double.greatestFiniteMagnitude
        }
        // print(santahh ?? [])
        XCTAssert(santahh == [3, 2, 0, 1, 2, 4, 3, 1, 4] || santahh == [4, 2, 0, 1, 2, 3, 4, 1, 3]
            || santahh == [3, 2, 4, 3, 1, 2, 0, 1, 4] || santahh == [4, 2, 3, 4, 1, 2, 0, 1, 3],
            "\(String(describing: santahh))")
        
        let total = -start.timeIntervalSinceNow
        print("Hierholzer:\t\t", total)
        return total
    }
    
    func heldKarp<G: Graph>(graph: G.Type) -> Double {
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
            [450, 43, 23, 72, 23, 61, 0]
        ]
        let g = MatrixGraph(matrix).convert(to: G.self)
        let res = g.bellmanHeldKarp(start: 0)!
        // print(res)
        XCTAssertEqual(res.0, [0, 1, 6, 2, 3, 4, 5, 0])
        XCTAssertEqual(res.1, 182)
        let total = -start.timeIntervalSinceNow
        print("bellmanHeldKarp:\t", total)
        return total
    }
    
    /*
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
     XCTAssert("\(k0)" ==
     "[(start: 2, end: 1, weight: -3), (start: 0, end: 1, weight: 1), (start: 0, end: 2, weight: 4)]", "\(k0)")
     // XCTAssert(g0.kruskal() == nil)
     let k1 = g1.kruskal() ?? []
     XCTAssert("\(k1)" ==
     "[(start: 2, end: 1, weight: -3), (start: 0, end: 1, weight: 1), (start: 2, end: 0, weight: 4)]"
     || "\(k1)" ==
     "[(start: 1, end: 2, weight: -3), (start: 0, end: 1, weight: 1), (start: 0, end: 2, weight: 4)]", "\(k1)")
     
     let total = -start.timeIntervalSinceNow
     print("Kruskal:\t\t\t", total)
     return total
     }
     */
    
    func nearestNeighbor<G: Graph>(graph: G.Type) -> Double {
        let start = Date()
        var g = G()
        for i in 0..<10 { g[i, i + 1] = 1 }
        g[5, 7] = -20
        XCTAssertNil(g.nearestNeighbor(start: 0))
        g[10, 6] = 1
        XCTAssertNil(g.nearestNeighbor(start: 0))
        let total = -start.timeIntervalSinceNow
        print("NearestNeighbor:\t", total)
        return total
    }
    
    func eulerian<G: Graph>(graph: G.Type) -> Double {
        let start = Date()
        var g = G()
        g[0, 1] = 1
        g[0, 2] = 4
        g[1, 2] = 1
        g[2, 1] = -3
        XCTAssert(g.directed)
        XCTAssertNil(g.unEvenVertices(directed: g.directed))
        XCTAssert(!g.semiEulerian)
        XCTAssert(!g.eulerian)
        g[1, 0] = 2
        XCTAssert(g.directed)
        XCTAssertEqual(g.unEvenVertices(directed: g.directed)!, 2)
        XCTAssert(g.semiEulerian)
        XCTAssert(!g.eulerian)
        g[2, 0] = 10
        XCTAssert(!g.directed)
        XCTAssertEqual(g.unEvenVertices(directed: g.directed)!, 0)
        XCTAssert(g.semiEulerian)
        XCTAssert(g.eulerian)
        let total = -start.timeIntervalSinceNow
        print("Eulerian:\t\t", total)
        return total
    }
}

func measureTime(_ fun: () throws -> Void) rethrows -> Double {
    let start = Date()
    try fun()
    return -start.timeIntervalSinceNow
}

func banner(_ string: String, count: Int = 40) -> String {
    guard string.characters.count < count else { return string }
    var result = " \(string) "
    while result.characters.count < count {
        result = "-\(result)-"
    }
    guard result.characters.count == count else { return String(result.characters.dropFirst()) }
    return result
}
