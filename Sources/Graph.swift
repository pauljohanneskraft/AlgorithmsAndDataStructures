//
//  Graph.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public protocol Graph {
	init()
	var vertices	: Set<Int>								{ get }
	var edges		: [(start: Int, end: Int, weight: Int)] { get set }
	subscript(start: Int			) -> [(end: Int, weight: Int)]	{ get }
	subscript(start: Int, end: Int	) -> Int?						{ get set }
}

extension Graph {
	
	public init(vertices: Set<Int>, rule: (Int, Int) throws -> Int?) rethrows {
		self.init()
		for start in vertices {
			for end in vertices {
				if let length = try rule(start, end) {
					self[start, end] = length
				}
			}
		}
	}
	
	public var noEmtpyVertices : Bool {
		for v in vertices {
			guard self[v].count > 0 else { return false }
		}
		return true
	}

    public func unEvenVertices(directed: Bool) -> Int? {
		var counts = [Int: (incoming: Int, outgoing: Int)]()
		for v in vertices { counts[v] = (0, 0) }
		for e in edges {
			let cstart	= counts[e.start]!
			let cend	= counts[e.end	]!
			counts[e.start	]! = (cstart.0,		cstart.1 + 1)
			counts[e.end	]! = (cend.0 + 1,	cend.1		)
		}
		var count = 0
        guard directed else {
            for c in counts {
                guard c.value.incoming == c.value.outgoing else { return nil }
                if c.value.incoming % 2 == 1 { count += 1 }
            }
            return count
        }
		for v in vertices {
			let c = counts[v]!
			if c.0 != c.1 {
				if abs(c.0 - c.1) == 1 {
					count += 1
				} else { return nil }
			}
		}
		return count

	}
		
	public var directed : Bool {
		for v in vertices {
			for e in self[v] {
				guard self[e.end].contains(where: { $0.end == v }) else { return true }
			}
		}
		return false
	}
	
	public var semiEulerian : Bool {
		var counts = [Int: (incoming: Int, outgoing: Int)]()
		for v in vertices { counts[v] = (0, 0) }
		for e in edges {
			let cstart	= counts[e.start]!
			let cend	= counts[e.end	]!
			counts[e.start	]! = (cstart.0,		cstart.1 + 1)
			counts[e.end	]! = (cend.0 + 1,	cend.1		)
		}
		var count = 0
		for v in vertices {
			let c = counts[v]!
			if c.0 != c.1 {
				if abs(c.0 - c.1) == 1 {
					count += 1
				} else { return false }
			}
		}
		return count == 2 || count == 0
	}
	
	public var eulerian : Bool {
		var counts = [Int: (incoming: Int, outgoing: Int)]()
		for v in vertices { counts[v] = (0, 0) }
		for e in edges {
			let cstart	= counts[e.start]!
			let cend	= counts[e.end	]!
			counts[e.start	]! = (cstart.0,		cstart.1 + 1)
			counts[e.end	]! = (cend.0 + 1,	cend.1		)
		}
		for v in vertices {
			let c = counts[v]!
			guard c.0 == c.1 else { return false }
		}
		return true
	}
	
	public func degree(of vertex: Int) -> Int {
		return self[vertex].count
	}
	
	public func convert< G : Graph >(to: G.Type) -> G {
		var a = to.init()
		a.edges = self.edges
		return a
	}
}

public func == (lhs: Graph, rhs: Graph) -> Bool {
	let le = lhs.edges
	let re = rhs.edges
	guard le.count == re.count else { return false }
	var sl = Set<HashableEdge>()
	var sr = Set<HashableEdge>()
	for i in le.indices {
		sl.insert(HashableEdge(value: le[i]))
		sr.insert(HashableEdge(value: re[i]))
	}
	return sl == sr
}

internal struct HashableEdge : Hashable {
	var value : (start: Int, end: Int, weight: Int)
	var hashValue: Int { return (value.start << 32) | value.end }
}

internal func == (lhs: HashableEdge, rhs: HashableEdge) -> Bool {
	return lhs.value == rhs.value
}







