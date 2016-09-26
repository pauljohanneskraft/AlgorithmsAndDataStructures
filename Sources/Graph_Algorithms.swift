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
