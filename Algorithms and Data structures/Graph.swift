//
//  Graph.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public protocol GraphProtocol {
    associatedtype V : VertexProtocol
    var vertices: [Int:V] { get }
}

public protocol VertexProtocol : Hashable, Comparable {
    mutating func removeAllEdges()
    var edges : [(key: Int, value: Int)] { get }
    subscript(_: Int) -> Int? { get set }
    var descriptionIncludingEdges: String { get }
}

public func < <V : VertexProtocol>(lhs: V, rhs: V) -> Bool {
    return lhs.hashValue < rhs.hashValue
}

public func == <V : VertexProtocol>(lhs: V, rhs: V) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

