//
//  Graph_Algorithms.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 17.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

extension Graph {
	
	public func depthFirstSearch<E,F>(
		start: Int,
		order: ((end: Int, weight: Int), (end: Int, weight: Int)) -> Bool = { $0.weight < $1.weight },
		onEntry: (Int) throws -> E, onFinish: (Int) throws -> F
		) rethrows -> (onEntry: [E], onFinish: [F]) {
		
		var visited = Set<Int>()
		return try dfs_rec(start: start, order: order, onEntry: onEntry, onFinish: onFinish, visited: &visited)
	}
	
	private func dfs_rec<E,F>(
		start current: Int,
		order: ((end: Int, weight: Int), (end: Int, weight: Int)) -> Bool,
		onEntry: (Int) throws -> E, onFinish: (Int) throws -> F,
		visited: inout Set<Int>
		) rethrows -> (onEntry: [E], onFinish: [F]) {
		
		var resultE = [try onEntry(current)]
		var resultF = [F]()
		
		visited.insert(current)
		
		for e in self[current].sorted(by: order) {
			if !visited.contains(e.end) {
				let e = try dfs_rec(start: e.end, order: order, onEntry: onEntry, onFinish: onFinish, visited: &visited)
				resultE.append(contentsOf: e.onEntry)
				resultF.append(contentsOf: e.onFinish)
			}
		}
		
		resultF.append(try onFinish(current))
		
		return (resultE, resultF)
	}
}

extension Graph {
	
	public func breadthFirstSearch<T>(start: Int, _ f: (Int) throws -> T) rethrows -> [T] {
		var visited = [Int:Int]()
		var list = [start]
		var result : [T] = []
		var current : Int
		
		visited[start] = start
		
		while !list.isEmpty {
			current = list.remove(at: 0)
			// print("visiting", current)
			let ends = self[current]
			for e in ends {
				if visited[e.end] == nil {
					// print(e)
					list.append(e.end)
					visited[e.end] = current
				}
			}
			result.append(try f(current))
		}
		return result
	}
}

extension Graph {
	
	public func djikstra(start: Int) -> [Int:(weight: Int, last: Int)] {
		var visited = [Int:(weight: Int, last: Int)]()
		
		djikstraRec(start: start, weights: 0, visited: &visited)
		
		return visited
	}
	
	public func djikstra(start: Int, end: Int) -> [Int] {
		let visited = djikstra(start: start)
		
		var result = [Int]()
		var current = end
		var next = Optional(end)
		repeat {
			current = next!
			next = visited[current]?.last
			result.append(current)
			if next == nil && current != start { return [] }
		} while current != start
		return result.reversed()
	}
	
	private func djikstraRec(start: Int, weights: Int, visited: inout [Int:(weight: Int, last: Int)]) {
		// print(start.hashValue)
		for v in self[start].sorted(by: { $0.weight < $1.weight }) {
			let weightAfterEdge = weights + v.weight
			// print(start.hashValue, " -?-> ", v.key, " with weight: ", weightAfterEdge)
			if let existingWeight = visited[v.end]?.weight {
				if weightAfterEdge < existingWeight {
					visited[v.end] = (weight: weightAfterEdge, last: start)
				} else { continue }
			} else { visited[v.end] = (weight: weightAfterEdge, last: start) }
			// print("\tvisited[\(v.key)] =", visited[v.key]!)
			djikstraRec(start: v.end, weights: weightAfterEdge, visited: &visited)
		}
	}
}

extension Graph {
	
	public func bellmanFord(start: Int) -> [Int:(weight: Int, last: Int)] {
		var visited = [Int:(weight: Int, last: Int)]()

		let edges = self.edges
		guard edges.count > 0 else { return [:] }
		visited[start] = (weight: 0, last: start)
		for _ in vertices {
			for e in edges {
				if var newWeight = visited[e.start]?.weight {
					newWeight += e.weight
					if let oldWeight = visited[e.end]?.weight {
						if newWeight < oldWeight {
							visited[e.end] = (weight: newWeight, last: e.start)
						}
					} else { visited[e.end] = (weight: newWeight, last: e.start) }
				}
			}
		}
		// print("done with djikstra")
		for e in edges {
			if var newWeight = visited[e.start]?.weight {
				if newWeight != Int.min { newWeight += e.weight
					if let oldWeight = visited[e.end]?.weight {
						if newWeight < oldWeight {
							infect(e.start, visited: &visited)
						}
					} else { assert(false) }
				}
			}
		}
		// print("done with bellmanFord")
		return visited
	}
	
	private func infect(_ start: Int,  visited: inout [Int:(weight: Int, last: Int)]) {
		// print("infected \(start)")
		visited[start] = (weight: Int.min, last: visited[start]!.last)
		for v in self[start] {
			if visited[v.end]?.weight != Int.min {
				visited[v.end] = (weight: Int.min, last: start)
				infect(v.end, visited: &visited)
			}
		}
	}
}

extension Graph {
	
	/*
	source:
		Title: Der Hierholzer Algorithmus
		Authors: Mark J. Becker, Wolfgang F. Riedl; Technische Universität München
		Link: https://www-m9.ma.tum.de/graph-algorithms/hierholzer
	*/
	
	public func hierholzer() -> [Int]? {
        guard noEmtpyVertices else { return nil }
        let unEvenVertices = self.unEvenVertices(directed: directed)
		guard unEvenVertices == 0 || unEvenVertices == 2 else { return nil }
        guard var start = vertices.first else { return nil }
        var end = start
		if unEvenVertices == 2 {
			// print("semiEulerian")
            var endpoints = [Int]()
			for v in vertices {
				if self[v].count % 2 == 1 {
                    // print(v, "is start")
					endpoints.append(v)
                    if endpoints.count > 1 { break }
                }
			}
            // print("endpoints", endpoints)
            if endpoints.count > 1 {
                start = endpoints[0]
                end = endpoints[1]
            }
            
		}
        
        // print(start)
		
        func hierholzer_rec() -> [[Int]]? {
            var subtour = [Int]()
            var tours = [[Int]]()
            var remainingEdges : [Int: Set<Int>] = [:]
            for v in vertices {
                remainingEdges[v] = Set(self[v].map { $0.end })
            }
            var visited : [Int: Set<Int>] = [:]
            
            repeat {
                subtour = [start]
                var current = start
                // print("new subtour starting at \(start) with remainingEdges:", remainingEdges)
                repeat {
                    // print(current, subtour, remainingEdges)
                    guard let next = remainingEdges[current]?.first(where: { self[$0, current] == nil }) ?? remainingEdges[current]?.first else {
                        if end != start {
                            swap(&start, &end)
                            // print("switching start and end")
                            return hierholzer_rec()
                        }
                        return nil
                    }
                    // print("\tvisiting \(end)")
                    
                    remainingEdges[current]!.remove(next)
                    _ = remainingEdges[next]?.remove(current)
                    if remainingEdges[current]!.isEmpty {
                        remainingEdges[current] = nil
                    }
                    if remainingEdges[next]?.isEmpty ?? false {
                        remainingEdges[next] = nil
                    }
                    
                    if visited[current] != nil	{ visited[current]!.insert(next) }
                    else						{ visited[current] = [next] }
                    if visited[next] != nil      { visited[next]!.insert(current) }
                    else						{ visited[next] = [current] }
                    
                    // print("\tbefore testing", remainingEdges)
                    
                    /*
                     if remainingEdges[end] == nil {
                     let set = Set(self[end].map { $0.end }).subtracting(visited[end] == nil ? [] : visited[end]!)
                     if !set.isEmpty { remainingEdges[end] = set }
                     }
                     */
                    
                    subtour.append(next)
                    current = next
                    
                    // print("\tdid visit \(end)", remainingEdges, visited)
                    
                } while !remainingEdges.isEmpty && (current != end || current != start)
                tours.append(subtour)
                start = remainingEdges.keys.first ?? start
                // print("end of subtour \(subtour) \(tours) \(remainingEdges)")
            } while !remainingEdges.isEmpty
            return tours
        }
        
        guard var tours = hierholzer_rec() else { return nil }
        // print("tries to join \(tours)")
        
        var tour = tours.first(where: { $0[$0.startIndex] == $0[$0.endIndex - 1] }) ?? tours[0]
        
        var didNotWork = 0
        tours.remove(at: 0)
        
        while !tours.isEmpty {
            // print(tours)
            guard didNotWork < tours.count else { /*print("failed to assemble");*/ return nil }
            var t = tours.first!
            if t[t.startIndex] == t[t.endIndex - 1] {
                if var index = tour.indices.first(where: { t.contains(tour[$0]) }) {
                    let i = t.indices.first(where: { tour[index] == t[$0] })!
                    // print(tour, t, "contains", tour[index], "at", i)
                    _ = t.popLast()
                    for _ in 0..<i { t.append(t.remove(at: 0)) }
                    for n in t {
                        tour.insert(n, at: index)
                        index += 1
                    }
                    didNotWork = 0
                    tours.remove(at: 0)
                    // print(t, "join successful \(tours)")
                } else {
                    didNotWork += 1
                    tours.append(tours.remove(at: 0))
                }
            } else if tours.count == 1 {
                // print("did enter")
                tour.remove(at: 0)
                var i = 0
                while tour.last! != t.first! {
                    guard i < tour.count else { return nil }
                    i += 1
                    tour.append(tour.remove(at: 0))
                }
                tours.remove(at: 0)
                tour.remove(at: tour.endIndex - 1)
                tour.insert(t.first!, at: 0)
                tour.append(contentsOf: t)
            } else {
                didNotWork += 1
                tours.append(tours.remove(at: 0))
            }
            
        }
        
		return tour
	}
	
}

extension Graph {
	
    public func nearestNeighbor(start: Int, lastPath finish: Bool = true) -> (path: [Int], distance: Int)? {
		var remaining = vertices
		var route = [start]
		var current = start
        remaining.remove(start)
		var length = 0
        for _ in 1..<vertices.count {
            guard let v = self[current].filter({ remaining.contains($0.end) }).min(by: { $0.weight < $1.weight }) else { return nil }
            current = v.end
            route.append(current)
            remaining.remove(current)
            length += v.weight

        }
        guard finish else { return (route, length) }
        guard let lastPath = self[route.last!, start] else { return nil }
        route.append(start)
        return (route, length + lastPath)
	}
	
}

extension Graph {
	
	public func kruskal() -> [(start: Int, end: Int, weight: Int)]? {
		guard !directed else { return nil }
		
		func hasCircle(from: Int, visited: Set<Int> = [], edges: [Int: Set<Int>]) -> Bool {
			var visited = visited
			var edges = edges
			for v in edges[from]! {
				edges[v]!.remove(from)
				// print("\tlooking at (\(from),\(v))", visited)
				guard !visited.contains(v) else { return true }
				visited.insert(v)
				guard !hasCircle(from: v, visited: visited, edges: edges) else { return true }
				visited.remove(v)
				edges[v]!.insert(from)
			}
			return false
		}
		
		var spanningTree = [(start: Int, end: Int, weight: Int)]()
		var visited = [Int:Set<Int>]()
		
		for v in vertices { visited[v] = Set<Int>() }
		
		for e in edges.sorted(by: { $0.weight < $1.weight }) {
			// print("checking out \(e)")
			spanningTree.append(e)
			visited[e.start	]!.insert(e.end		)
			visited[e.end	]!.insert(e.start	)
			if hasCircle(from: e.start, edges: visited) || hasCircle(from: e.end, edges: visited) {
				// print("removing \(e)")
				spanningTree.removeLast()
				visited[e.start]!.remove(e.end)
			}
		}
		return spanningTree
	}
	
	
}

public extension Graph {
    public func bellmanHeldKarp(start: Int) -> (path: [Int], distance: Int)? {
        let semaphore = DispatchSemaphore(value: 1)
        
        guard var nearestNeighbor = self.nearestNeighbor(start: start, lastPath: true) else { return nil }
        
        var bestAnswer = nearestNeighbor // { didSet { print(bestAnswer) } }
        
        func heldKarp_rec(from: Int, start: Int, path visited: [Int], visit: Set<Int>, distance: Int, maxDistance: Int) -> Int {
            guard distance < maxDistance else { return maxDistance }
            let visited = visited + [start]
            var visit = visit
            _ = visit.remove(start)
            guard !visit.isEmpty else {
                if let lastPath = self[start, from] {
                    let fullDistance = distance + lastPath
                    if fullDistance < maxDistance {
                        let result = (path: visited + [from], distance: fullDistance)
                        semaphore.wait()
                        defer { semaphore.signal() }
                        if result.distance < bestAnswer.distance {
                            bestAnswer = result
                            // print(bestAnswer)
                        }
                        return bestAnswer.distance
                    }
                    
                }
                return maxDistance
            }
            var minDistance = maxDistance
            // print(visit.count)
            // print(start, visit.sorted(), visited, distance)
            for v in visit.filter({ if let w = self[start, $0] { return distance + w < minDistance } else { return false } }).sorted(by: {
                self[start, $0]! < self[start, $1]!
            }) {
                // print(minDistance)
                // guard v != start else { continue }
                if let edge_weight = self[start, v] {
                    visit.remove(v)
                    let m = heldKarp_rec(from: from, start: v, path: visited, visit: visit, distance: edge_weight + distance, maxDistance: minDistance)
                    minDistance = max(minDistance, m)
                    visit.insert(v)
                }
            }
            
            return minDistance
        }
        
        let queue = DispatchQueue(label: "heldKarp", attributes: .concurrent)
        let group = DispatchGroup()
        var vs = vertices
        vs.remove(start)
        // print("start", start, vs.sorted())
        var minDistance = nearestNeighbor.distance
        var i = 0
        for e in self[start].sorted(by: { $0.weight < $1.weight }) {
            i += 1
            guard e.end != start else { continue }
            queue.async(group: group) {
                let m = heldKarp_rec(from: start, start: e.end, path: [start], visit: vs, distance: e.weight, maxDistance: minDistance)
                semaphore.wait()
                minDistance = max(minDistance, m)
                semaphore.signal()
                // print("e.end \(e.end) done")
            }
            if i % 5 == 4 {
                group.wait()
                semaphore.wait()
                minDistance = bestAnswer.distance
                semaphore.signal()
            }
        }
        group.wait()
        // print("answers", answers)
        return bestAnswer
    }
    
}



/*
 */








