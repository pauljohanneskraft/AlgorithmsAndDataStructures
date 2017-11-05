//
//  Graph_List.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct GraphList: Graph {
	
	// stored properties
	public var edges: Set<GraphEdge>
    
	// initializiers
	public init() { edges = [] }

	// computed properties
	public var vertices: Set<Int> {
		var set = Set<Int>()
		for e in edges {
			set.insert(e.start)
			set.insert(e.end)
		}
		return set
	}

	// subscripts
	public subscript(start: Int, end: Int) -> Int? {
		get {
            return edges.first(where: { $0.start == start && $0.end == end })?.weight
		}
		set {
            let ind = edges.indices.filter { edges[$0].start == start && edges[$0].end == end }
            for i in ind.reversed() { edges.remove(at: i) }
            guard let newValue = newValue else { return }
            edges.insert(GraphEdge(start: start, end: end, weight: newValue))
		}
	}

	public subscript(start: Int) -> [(end: Int, weight: Int)] {
        return edges
            .filter { $0.start == start }
            .map { (end: $0.end, weight: $0.weight) }
            .sorted { $0.end < $1.end }
	}

}
