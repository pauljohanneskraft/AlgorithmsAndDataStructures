//
//  MatrixGraph.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct MatrixGraph: Graph, CustomStringConvertible {
	
	// stored properties
	public private(set) var internalEdges: [[Int?]]
	
	// initializers
	public init() { internalEdges = [] }
    
    public init(_ matrix: [[Int?]]) {
        self.internalEdges = matrix
    }
	
	// computed properties
	public var edges: Set<GraphEdge> {
		get {
            return Set(internalEdges.indices.flatMap { arrayIndex in
                internalEdges[arrayIndex].indices.flatMap { elementIndex in
                    guard let weight = internalEdges[arrayIndex][elementIndex] else {
                        return nil
                    }
                    return GraphEdge(start: arrayIndex, end: elementIndex, weight: weight)
                }
            })
		}
		set {
			internalEdges = []
			for e in newValue { self[e.start, e.end] = e.weight }
		}
	}
	
	public var vertices: Set<Int> {
        return Set((0..<internalEdges.count).filter { vertex in
            guard !internalEdges[vertex].contains(where: { $0 != nil }) else { return true }
            
            for i in internalEdges.indices {
                guard internalEdges[i][vertex] == nil else { return true }
            }
            
            return false
        })
	}
	
	public var description: String {
		var result = "Graph_Matrix:\n\t\t \t"
		for i in internalEdges.indices {
			result += "\(i)\t"
		}
		result += " \n"
		for startIndex in internalEdges.indices {
			result += "\t\(startIndex):\t[\t"
			for i in internalEdges[startIndex] {
                if let i = i {
                    result += "\(i)"
                } else {
                    result += "."
                }
                result += "\t"
			}
			result += "]\n"
		}
		return result
	}
	
	private var invariant: Bool {
		guard internalEdges.count > 0 else { return true }
		let b = internalEdges[0].count
		if internalEdges.count != b { return false }
        guard !internalEdges.dropFirst().contains(where: { $0.count != b }) else {
            return false
        }
		return true
	}
	
	// subscripts
	public subscript(start: Int) -> [(end: Int, weight: Int)] {
		guard internalEdges.indices.contains(start) else { return [] }
        return internalEdges[start].indices.flatMap {
            guard let weight = internalEdges[start][$0] else {
                return nil
            }
            return (end: $0, weight: weight)
        }
	}
	
	public subscript(start: Int, end: Int) -> Int? {
		get {
			guard internalEdges.indices.contains(start) else { return nil }
			guard internalEdges[start].indices.contains(end) else { return nil }
			assert(invariant, "Invariant conflict. \(self)")
			return internalEdges[start][end]
		}
		set {
            
            defer { assert(invariant, "Invariant conflict. \(self)") }
            
			if internalEdges.count == 0 { internalEdges = [[nil]] }
            
            let diff = (max(start, end) + 1) - internalEdges.count
			
            if diff > 0 {
                let newPart = [Int?](repeating: nil, count: diff)
                for i in internalEdges.indices { internalEdges[i].append(contentsOf: newPart) }
                for _ in 0..<diff { internalEdges.append([Int?](repeating: nil, count: internalEdges[0].count)) }
            }
            
            defer {
                let negDiff = internalEdges.count - ((vertices.max() ?? 0) + 1)
                if negDiff > 0 {
                    for i in internalEdges.indices { internalEdges[i] = Array(internalEdges[i].dropLast(negDiff)) }
                    internalEdges = Array(internalEdges.dropLast(negDiff))
                }
            }
            
			internalEdges[start][end] = newValue
		}
	}
	
}
