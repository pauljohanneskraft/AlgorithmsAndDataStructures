//
//  Graph_AdjacencyList.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct Graph_AdjacencyList : Graph, CustomStringConvertible {
	var edges : [Int: [(end: Int, weight: Int)] ]
	
	public subscript(start: Int, end: Int) -> Int? {
		get {
			let a = edges[start]
			guard a != nil else { return nil }
			for e in a! {
				if e.end == end { return e.weight }
			}
			return nil
		}
		set {
			if edges[start] == nil {
				if newValue == nil { return }
				edges[start] = [(end, newValue!)]
			}
			else {
				let e = edges[start]!
				for i in e.indices {
					if e[i].end == end {
						if newValue == nil	{ edges[start]![i] = (end: end, weight: newValue!) }
						else				{ _ = edges[start]!.remove(at: i) }
						return
					}
				}
				if newValue == nil { return }
				edges[start]!.append((end, newValue!))
			}
		}
	}
	
	public subscript(start: Int) -> [(end: Int, weight: Int)]? {
		return edges[start]
	}
	
	public init() { edges = [:] }
	
	public var description : String {
		var result = "Graph_AdjacencyList:\n"
		for i in edges.keys.sorted() {
			result += "\t\(i):\t\(edges[i]!)\n"
		}
		return result
	}
	
}
