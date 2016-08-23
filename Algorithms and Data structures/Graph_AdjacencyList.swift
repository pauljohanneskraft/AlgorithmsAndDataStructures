//
//  Graph_AdjacencyList.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct Graph_AdjacencyList : Graph, CustomStringConvertible {
	
	// stored properties
	public var _edges : [Int: [(end: Int, weight: Int)] ]
	
	// initializers
	public init() { _edges = [:] }
	
	// computed properties
	public var edges : [(start: Int, end: Int, weight: Int)] {
		get {
			var result : [(start: Int, end: Int, weight: Int)] = []
			for e in _edges {
				for v in e.value {
					result.append((e.key, v.end, v.weight))
				}
			}
			return result
		}
		set {
			_edges = [:]
			for e in newValue { self[e.start, e.end] = e.weight }
		}
	}
	
	public var vertices: Set<Int> {
		return Set(_edges.keys)
	}
	
	public var description : String {
		var result = "Graph_AdjacencyList:\n"
		for i in _edges.keys.sorted() {
			result += "\t\(i):\t\(_edges[i]!)\n"
		}
		return result
	}
	
	// subscripts
	public subscript(start: Int, end: Int) -> Int? {
		get {
			let a = _edges[start]
			guard a != nil else { return nil }
			for e in a! {
				if e.end == end { return e.weight }
			}
			return nil
		}
		set {
			if _edges[start] == nil {
				if newValue == nil { return }
				_edges[start] = [(end, newValue!)]
			}
			else {
				let e = _edges[start]!
				for i in e.indices {
					if e[i].end == end {
						if newValue == nil	{ _edges[start]![i] = (end: end, weight: newValue!) }
						else				{ _ = _edges[start]!.remove(at: i) }
						return
					}
				}
				if newValue == nil { return }
				_edges[start]!.append((end, newValue!))
			}
		}
	}
	
	public subscript(start: Int) -> [(end: Int, weight: Int)] {
		let e = _edges[start]
		return e == nil ? [] : e!
	}
	
}
