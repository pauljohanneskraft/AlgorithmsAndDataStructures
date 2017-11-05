//
//  Graph_Hashing.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct GraphHashing: Graph, CustomStringConvertible {
	
	// stored properties
	public var internalEdges: [Int: [Int: Int]]
    
	// initializers
	public init() { internalEdges = [:] }
	
	// computed properties
	public var edges: Set<GraphEdge> {
		get {
			return Set(internalEdges.flatMap { (key, value) in
                value.map { GraphEdge(start: key, end: $0.key, weight: $0.value) }
            })
		}
		set {
			internalEdges = [:]
			for e in newValue { self[e.start, e.end] = e.weight }
		}
	}
	
	public var vertices: Set<Int> {
        var set = Set<Int>()
        for e in internalEdges {
            set.insert(e.key)
            for edge in e.value { set.insert(edge.key) }
        }
        return set
    }
	
	public var description: String {
		var str = "Graph_Hashing:\n"
		for start in internalEdges.sorted(by: { $0.0 < $1.0 }) {
			str += "\tVertex \(start.key):\n"
			for end in start.value.sorted(by: { $0.0 < $1.0 }) {
				str += "\t\t- Vertex \(end.key): \(end.value)\n"
			}
		}
		return str
	}
	
	// subscripts
	public subscript(start: Int) -> [(end: Int, weight: Int)] {
		if internalEdges[start] == nil { return [] }
		return internalEdges[start]!.map { $0 }
	}
	
	public subscript(start: Int, end: Int) -> Int? {
		get { return internalEdges[start]?[end]		}
		set {
            if newValue != nil {
                if internalEdges [ start ] == nil { internalEdges [ start ] = [:] }
                if internalEdges [  end  ] == nil { internalEdges [  end  ] = [:] }
            }
			
            defer {
                if internalEdges[start]?.isEmpty ?? false { internalEdges[start] = nil }
                if internalEdges[ end ]?.isEmpty ?? false { internalEdges[ end ] = nil }
            }
            
			internalEdges [start]! [end] = newValue
		}
	}
}
