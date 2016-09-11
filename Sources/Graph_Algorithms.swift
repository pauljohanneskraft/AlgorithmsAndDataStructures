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
	
	public func djikstra(start: Int, end: Int) -> [Int] {
		guard start != end else { return [] }
		var visited = [Int:(weight: Int, last: Int)]()
		
		djikstraRec(start: start, end: end, weights: 0, visited: &visited)
		
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
	
	private func djikstraRec(start: Int, end: Int, weights: Int, visited: inout [Int:(weight: Int, last: Int)]) {
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
			djikstraRec(start: v.end, end: end, weights: weightAfterEdge, visited: &visited)
		}
	}
}
	
extension Graph {
	
	public func bellmanFord(start: Int, end: Int) -> [Int] {

		guard start != end else { return [] }
		
		var visited = [Int:(weight: Int, last: Int)]()
		bellmanFordRec(start: start, end: end, weights: 0, visited: &visited)
		
		var result = [Int]()
		var current : Int	= end.hashValue
		var next	: Int?	= current
		repeat {
			current = next!
			next = visited[current]?.last.hashValue
			result.append(current)
			if next == nil && current != start.hashValue { return [] }
		} while current != start.hashValue
		return result.reversed()
	}
	
	private func bellmanFordRec(start: Int, end: Int, weights: Int, visited: inout [Int:(weight: Int, last: Int)]) {
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
			bellmanFordRec(start: v.end, end: end, weights: weightAfterEdge, visited: &visited)
		}
	}
}




