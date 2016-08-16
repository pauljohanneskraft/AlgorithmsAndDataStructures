//
//  Graph_Hashing.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation



public struct Vertex : VertexProtocol, CustomStringConvertible {
	public var edges: [(key: Int, value: Int)] { return _edges.map { $0 } }
    public var _edges = [Int:Int]()
    public var hashValue: Int
    var name: String
	
	public subscript(_ i: Int) -> Int? {
		get { return _edges[i] }
		set { _edges[i] = newValue }
	}
	
    public init(value: Int, name: String = "Vertex") {
        self.hashValue = value
        self.name = name
    }
    
    public mutating func removeAllEdges() {
        _edges = [:]
    }
    
    public var description: String {
        return "\(name) \(hashValue)"
    }
    
    public var descriptionIncludingEdges: String {
        return description + ", edges to: \(Array(_edges.sorted { $0.key < $1.key }))"
    }
}

public func == (lhs: Vertex, rhs: Vertex) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public struct Graph_Hashing<V : VertexProtocol> : CustomStringConvertible, GraphProtocol {
	
    private(set) public var vertices : [Int:V] = [:]
	
	public var rule: (_ start: V, _ end: V) -> Int? {
        willSet {
            for start in vertices.keys {
                vertices[start]!.removeAllEdges()
                for end in vertices.keys {
                    if let w = newValue(vertices[start]!, vertices[end]!) {
                        vertices[start]![vertices[end.hashValue]!.hashValue] = w
                    }
                    if let w = newValue(vertices[end]!, vertices[start]!) {
                        vertices[end]![vertices[start.hashValue]!.hashValue] = w
					}
                }
            }
        }
    }
	public init(rule r: @escaping (_: V, _: V) -> Int?) {
        self.rule = r
    }
    public mutating func insert(_ vertex: V) {
        guard vertices[vertex.hashValue] == nil else { return }
        var vertex = vertex
        for i in vertices.keys {
            if let w = rule(vertices[i]!, vertex) { vertices[i.hashValue]![vertex.hashValue] = w }
            if let w = rule(vertex, vertices[i]!) { vertex[vertices[i.hashValue]!.hashValue] = w }
        }
        vertices[vertex.hashValue] = vertex
    }
    
    public var description: String {
        var verticesString = "\n"
        for v in vertices.values.sorted() {
            verticesString += "\t\(v.descriptionIncludingEdges)\n"
        }
        return "AsymmetricalGraph with vertices: \(verticesString)"
    }
    
}
