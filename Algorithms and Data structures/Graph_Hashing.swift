//
//  Graph_Hashing.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct Graph_Hashing : Graph, CustomStringConvertible {
	public var edges : [Int:[Int:Int]]
	
	public init() {
		edges = [:]
	}
	
	public init(edges: [Int:[Int:Int]]) {
		self.edges = edges
	}
	
	public subscript(start: Int) -> [(end: Int, weight: Int?)]? {
		return edges[start]?.map { $0 }
	}
	public subscript(start: Int, end: Int) -> Int? {
		get { return edges[start]?[end]		}
		set {
			if edges [ start ] == nil { edges [ start ] = [ : ] }
			if edges [  end  ] == nil { edges [  end  ] = [ : ] }
			edges [start]! [end] = newValue
		}
	}
	public var description: String {
		var str = "Graph_Hashing:\n"
		for start in edges.sorted(by: { $0.0 < $1.0 }) {
			str += "\tVertex \(start.key):\n"
			for end in start.value.sorted(by: { $0.0 < $1.0 }) {
				str += "\t\t- Vertex \(end.key): \(end.value)\n"
			}
		}
		return str
	}
}
