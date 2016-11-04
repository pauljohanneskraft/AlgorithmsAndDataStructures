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
		guard noEmtpyVertices && simple else { return nil }
		let unEvenVertices = self.unEvenVertices
		guard unEvenVertices == 0 || unEvenVertices == 2 else { return nil }
		guard var start = vertices.first else { return nil }
		if unEvenVertices == 2 {
			print("semiEulerian")
			for v in vertices {
				if self[v].count % 2 == 1 {
					start = v
					break
				}
			}
		}
		
		var subtour = [Int]()
		var tour = [Int]()
		var remainingEdges : [Int: Set<Int>] = [:]
		remainingEdges[start] = Set(self[start].map { $0.end })
		var visited : [Int: Set<Int>] = [:]
		
		repeat {
			start = remainingEdges.keys.first!
			subtour = [start]
			var current = start
			// print("new subtour starting at \(start) with remainingEdges:", remainingEdges)
			repeat {
				let end = remainingEdges[current]!.first!
				// print("\tvisiting \(end)")

				remainingEdges[current]!.remove(end)
				if remainingEdges[current]!.isEmpty { remainingEdges[current] = nil }
				if visited[current] != nil	{ visited[current]!.insert(end) }
				else						{ visited[current] = [end] }
				
				// print("\tbefore testing", remainingEdges)
				
				if remainingEdges[end] == nil {
					let set = Set(self[end].map { $0.end }).subtracting(visited[end] == nil ? [] : visited[end]!)
					if !set.isEmpty { remainingEdges[end] = set }
				}
				
				subtour.append(end)
				current = end
				
				// print("\tdid visit \(end)", remainingEdges, visited)
				
			} while current != start
			tour.append(contentsOf: subtour)
			// print("end of subtour \(subtour)")
		} while !remainingEdges.keys.isEmpty
		
		return tour
	}
	
}

extension Graph {
	
	public func nearestNeighbor(start: Int) -> ([Int], Int)? {
		var visited = Set<Int>()
		var route = [Int]()
		var current = start
		var length = 0
		while true {
			// print(current, "->", terminator: "")
			route.append(current)
			visited.insert(current)
			guard visited != vertices else { return (route, length) }
			let v = self[current].min(by: { !visited.contains($0.end) && $0.weight < $1.weight })
			guard v != nil && !visited.contains(v!.end) else { return nil }
			current = v!.end
			length += v!.weight
		}
	}
	
}

extension Graph {
	
	public func kruskal() -> [(start: Int, end: Int, weight: Int)]? {
		guard self.simple else { return nil }
		
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







