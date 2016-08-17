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
	subscript(start: Int) -> [(end: Int, weight: Int?)]? { get }
	subscript(start: Int, end: Int) -> Int? { get set }
}

extension Graph {
	public init(_ edges: (start: Int, end: Int, weight: Int?)...) {
		self.init()
		for e in edges {
			self[e.start, e.end] = e.weight
		}
	}
}
