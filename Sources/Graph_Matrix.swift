//
//  Graph_Matrix.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct Graph_Matrix : Graph, CustomStringConvertible {
	
	// stored properties
	public private(set) var _edges : [[Int?]]
	
	// initializers
	public init() { _edges = [] }
	
	// computed properties
	public var edges: [(start: Int, end: Int, weight: Int)] {
		get {
			var result = [(start: Int, end: Int, weight: Int)]()
			for i in _edges.indices {
				let ei = _edges[i]
				for j in ei.indices {
					if ei[j] != nil { result.append((i, j, ei[j]!)) }
				}
			}
			return result
		}
		set {
			_edges = []
			for e in newValue { self[e.start, e.end] = e.weight }
		}
	}
	
	public var vertices: Set<Int> {
		return Set(0..<_edges.count)
	}
	
	public var description: String {
		var result = "Graph_Matrix:\n\t\t \t"
		for i in _edges.indices {
			result += "\(i)\t"
		}
		result += " \n"
		for startIndex in _edges.indices {
			result += "\t\(startIndex):\t[\t"
			for i in _edges[startIndex] {
				if i == nil		{ result +=     ".\t" }
				else			{ result += "\(i!)\t" }
			}
			result += "]\n"
		}
		return result
	}
	
	private var invariant : Bool {
		guard _edges.count > 0 else { return true }
		let b = _edges[0].count
		if _edges.count != b { return false }
		for e in _edges.dropFirst() {
			if b != e.count { return false }
		}
		return true
	}
	
	// subscripts
	public subscript(start: Int) -> [(end: Int, weight: Int)] {
		guard _edges.indices.contains(start) else { return [] }
		return _edges[start].indices.filter({ _edges[start][$0] != nil }).map { (end: $0, weight: _edges[start][$0]!) }
	}
	
	public subscript(start: Int, end: Int) -> Int? {
		get {
			guard _edges.indices.contains(start) else { return nil }
			guard _edges[start].indices.contains(end) else { return nil }
			assert(invariant, "Invariant conflict. \(self)")
			return _edges[start][end]
		}
		set {
			if _edges.count == 0 { _edges = [[nil]] }
			
			while !_edges.indices.contains(start) {
				for i in _edges.indices { _edges[i].append(nil) }
				_edges.append([Int?](repeating: nil, count: _edges[0].count))
			}
			
			while !_edges[start].indices.contains(end) {
				for i in _edges.indices { _edges[i].append(nil) }
				_edges.append([Int?](repeating: nil, count: _edges[0].count))
			}
			
			assert(invariant, "Invariant conflict. \(self)")
			
			_edges[start][end] = newValue
		}
	}
	
}
