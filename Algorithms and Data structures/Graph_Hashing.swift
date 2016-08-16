//
//  Graph_Hashing.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation



public struct Vertex : VertexProtocol, CustomStringConvertible {
    public var edges : [(Int, Int)] { return _edges.map { $0 } }
    public var _edges = [Int:Int]()
    public var hashValue: Int
    var name: String
    
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
    public var rule: (start: V, end: V) -> Int? {
        willSet {
            for start in vertices.keys {
                vertices[start]!.removeAllEdges()
                for end in vertices.keys {
                    if let w = newValue(start: vertices[start]!, end: vertices[end]!) {
                        vertices[start]!.addEdge(vertices[end.hashValue]!.hashValue, weight: w)
                    }
                    if let w = newValue(start: vertices[end]!, end: vertices[start]!) {
                        vertices[end]!.addEdge(vertices[start.hashValue]!.hashValue, weight: w)
                    }
                }
            }
        }
    }
    public init(rule: (start: V, end: V) -> Int?) {
        self.rule = rule
    }
    public mutating func insert(_ vertex: V) {
        guard vertices[vertex.hashValue] == nil else { return }
        var vertex = vertex
        for i in vertices.keys {
            if let w = rule(start: vertices[i]!, end: vertex) { vertices[i.hashValue]!.addEdge(vertex.hashValue, weight: w) }
            if let w = rule(start: vertex, end: vertices[i]!) { vertex.addEdge(vertices[i.hashValue]!.hashValue, weight: w) }
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
