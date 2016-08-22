//
//  Graph_Algorithms.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 17.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

extension Graph {
	
	public func djikstra(start: Int, end: Int) -> [Int] {
		assert(self[start] != nil, "Start is not part of graph.")
		assert(self[end] != nil, "End is not part of graph.")
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
		for v in self[start]!.sorted(by: { $0.weight < $1.weight }) {
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
	
	public func bellmanFord(start: Int, end: Int) -> [Int] {
		assert(self[start] != nil && self[end] != nil, "Start or end is not part of graph.")
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
		for v in self[start]!.sorted(by: { $0.weight < $1.weight }) {
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




