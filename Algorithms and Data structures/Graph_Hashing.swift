//
//  Graph_Hashing.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct Graph_Hashing : Graph, CustomStringConvertible {
	
	// stored properties
	public var _edges : [Int:[Int:Int]]
	
	// initializers
	public init()						{ self._edges = [:]		}
	public init(edges: [Int:[Int:Int]]) { self._edges = edges	}
	
	// computed properties
	public var edges : [(start: Int, end: Int, weight: Int)] {
		get {
			var result = [(start: Int, end: Int, weight: Int)]()
			for e in _edges {
				for i in e.value { result.append((e.key, i.key, i.value)) }
			}
			return result
		}
		set {
			_edges = [:]
			for e in newValue { self[e.start, e.end] = e.weight }
		}
	}
	
	public var vertices: Set<Int> { return Set(_edges.keys) }
	
	public var description: String {
		var str = "Graph_Hashing:\n"
		for start in _edges.sorted(by: { $0.0 < $1.0 }) {
			str += "\tVertex \(start.key):\n"
			for end in start.value.sorted(by: { $0.0 < $1.0 }) {
				str += "\t\t- Vertex \(end.key): \(end.value)\n"
			}
		}
		return str
	}
	
	// subscripts
	public subscript(start: Int) -> [(end: Int, weight: Int)] {
		if _edges[start] == nil { return [] }
		return _edges[start]!.map { $0 }
	}
	
	public subscript(start: Int, end: Int) -> Int? {
		get { return _edges[start]?[end]		}
		set {
			if _edges [ start ] == nil { _edges [ start ] = [ : ] }
			if _edges [  end  ] == nil { _edges [  end  ] = [ : ] }
			_edges [start]! [end] = newValue
		}
	}
}
