//
//  Graph_Algorithms.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 17.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

extension GraphProtocol {
	public func djikstra(start: V, end: V) -> [Int] {
		assert(vertices[start.hashValue] != nil && vertices[end.hashValue] != nil, "Start or end is not part of graph.")
		guard start != end else { return [] }
		var visited = [Int:(weight: Int, last: V)]()
		djikstraRec(start: start, end: end, weights: 0, visited: &visited)
		let v = visited.sorted { $0.key < $1.key }
		print("visited:")
		for i in v {
			print("\t", i)
		}
		var result = [Int]()
		var current = end.hashValue
		var next = Optional(end)?.hashValue
		repeat {
			current = next!.hashValue
			next = visited[current]?.last.hashValue
			result.append(current)
			if next == nil && current != start.hashValue { return [] }
		} while current != start.hashValue
		return result.reversed()
	}
	
	private func djikstraRec(start: V, end: V, weights: Int, visited: inout [Int:(weight: Int, last: V)]) {
		// print(start.hashValue)
		for v in start.edges.sorted(by: { $0.key < $1.key }) {
			let weightAfterEdge = weights + v.value
			// print(start.hashValue, " -?-> ", v.key, " with weight: ", weightAfterEdge)
			if let existingWeight = visited[v.key]?.weight {
				if weightAfterEdge < existingWeight {
					visited[v.key] = (weight: weightAfterEdge, last: start)
				} else { continue }
			} else { visited[v.key] = (weight: weightAfterEdge, last: start) }
			// print("\tvisited[\(v.key)] =", visited[v.key]!)
			djikstraRec(start: vertices[v.key]!, end: end, weights: weightAfterEdge, visited: &visited)
		}
	}
	
	public func bellmanFord(start: V, end: V) -> [Int] {
		assert(vertices[start.hashValue] != nil && vertices[end.hashValue] != nil, "Start or end is not part of graph.")
		guard start != end else { return [] }
		var visited = [Int:(weight: Int, last: V)]()
		bellmanFordRec(start: start, end: end, weights: 0, visited: &visited)
		let v = visited.sorted { $0.key < $1.key }
		print("visited:")
		for i in v {
			print("\t", i)
		}
		var result = [Int]()
		var current = end.hashValue
		var next = Optional(end)?.hashValue
		repeat {
			current = next!.hashValue
			next = visited[current]?.last.hashValue
			result.append(current)
			if next == nil && current != start.hashValue { return [] }
		} while current != start.hashValue
		return result.reversed()
	}
	
	private func bellmanFordRec(start: V, end: V, weights: Int, visited: inout [Int:(weight: Int, last: V)]) {
		// print(start.hashValue)
		for v in start.edges.sorted(by: { $0.key < $1.key }) {
			let weightAfterEdge = weights + v.value
			// print(start.hashValue, " -?-> ", v.key, " with weight: ", weightAfterEdge)
			if let existingWeight = visited[v.key]?.weight {
				if weightAfterEdge < existingWeight {
					visited[v.key] = (weight: weightAfterEdge, last: start)
				} else { continue }
			} else { visited[v.key] = (weight: weightAfterEdge, last: start) }
			// print("\tvisited[\(v.key)] =", visited[v.key]!)
			bellmanFordRec(start: vertices[v.key]!, end: end, weights: weightAfterEdge, visited: &visited)
		}
	}
}












