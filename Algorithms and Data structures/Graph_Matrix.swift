//
//  Graph_Matrix.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct Graph_Matrix : Graph, CustomStringConvertible {
	public private(set) var edges : [[Int?]]
	
	public init() {
		edges = []
	}
	
	public subscript(start: Int) -> [(end: Int, weight: Int?)]? {
		guard edges.indices.contains(start) else { return nil }
		var i = -1
		return edges[start].map { i += 1; return (end: i, weight: $0) }
	}
	
	public subscript(start: Int, end: Int) -> Int? {
		get {
			guard edges.indices.contains(start) else { return nil }
			guard edges[start].indices.contains(end) else { return nil }
			return edges[start][end]
		}
		set {
			if edges.count == 0 { edges = [[nil]] }
			
			while !edges.indices.contains(start) {
				edges.append([Int?](repeating: nil, count: edges[0].count))
			}
			
			while !edges[start].indices.contains(end) {
				for i in edges.indices {
					edges[i].append(nil)
				}
				edges.append([Int?](repeating: nil, count: edges[0].count))
			}
			
			edges[start][end] = newValue
		}
	}
	
	public var description: String {
		var result = "Graph_Matrix:\n\t\t \t"
		for i in edges.indices {
			result += "\(i)\t"
		}
		result += " \n"
		for startIndex in edges.indices {
			result += "\t\(startIndex):\t[\t"
			for i in edges[startIndex] {
				if i == nil { result += ".\t" }
				else { result += "\(i!)\t" }
			}
			result += "]\n"
		}
		return result
	}
	
}
