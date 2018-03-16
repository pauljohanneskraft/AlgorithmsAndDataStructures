//
//  AdjacencyListGraph.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct AdjacencyListGraph: Graph, CustomStringConvertible {
	
	// stored properties
	public var internalEdges: [Int: [(end: Int, weight: Int)] ]
	
	// initializers
	public init() { internalEdges = [:] }
	
	// computed properties
	public var edges: Set<GraphEdge> {
		get {
            return Set(internalEdges.flatMap { (key, value) in
                value.map { GraphEdge(start: key, end: $0.end, weight: $0.weight) }
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
            for edge in e.value { set.insert(edge.end) }
        }
        return set
    }
	
	public var description: String {
		var result = "Graph_AdjacencyList:\n"
		for i in internalEdges.keys.sorted() {
			result += "\t\(i):\t\(internalEdges[i]!)\n"
		}
		return result
	}
	
	// subscripts
	public subscript(start: Int, end: Int) -> Int? {
		get {
			let a = internalEdges[start]
			guard a != nil else { return nil }
			for e in a! { guard e.end != end else { return e.weight } }
			return nil
		}
		set {
            if newValue != nil {
                if internalEdges[start] == nil { internalEdges[start] = [] }
                if internalEdges[ end ] == nil { internalEdges[ end ] = [] }
            }
            
            defer {
                if internalEdges[start]?.isEmpty ?? false { internalEdges[start] = nil }
                if internalEdges[ end ]?.isEmpty ?? false { internalEdges[ end ] = nil }
            }
            
            internalEdges[start]! = internalEdges[start]!.filter({ $0.end != end })
            guard newValue != nil else { return }
            internalEdges[start]!.append((end, newValue!))
		}
	}
	
	public subscript(start: Int) -> [(end: Int, weight: Int)] {
		return internalEdges[start] ?? []
	}
	
}
