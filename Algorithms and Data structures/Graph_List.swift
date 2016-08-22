//
//  Graph_List.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

public struct Graph_List : Graph {
	public subscript(start: Int, end: Int) -> Int? {
		get {
			for e in edges {
				if e.start == start && e.end == end { return e.weight }
			}
			return nil
		}
		set {
			for i in edges.indices {
				let e = edges[i]
				if e.start == start && e.end == end {
					if newValue == nil	{ _ = edges.remove(at: i) }
					else				{ edges[i] = (start, end, newValue!) }
					return
				}
			}
			if newValue == nil { return }
			edges.append((start, end, newValue!))
		}
	}

	public subscript(start: Int) -> [(end: Int, weight: Int)]? {
		var result = [(end: Int, weight: Int)]()
		for e in edges {
			if start == e.start { result.append((e.end, e.weight)) }
		}
		return result
	}

	var edges : [(start: Int, end: Int, weight: Int)]
	
	public init() { edges = [] }
	
	
}

