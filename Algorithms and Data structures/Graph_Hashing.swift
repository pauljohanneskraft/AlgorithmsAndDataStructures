//
//  Graph_Hashing.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public protocol VertexProtocol : Hashable, Comparable {
    func getWeight(_ vertex: Int) -> Int?
    mutating func addEdge(_ vertex: Int, weight: Int)
    mutating func removeEdge(_ vertex: Int)
    mutating func removeAllEdges()
    var edges : [Int:Int] { get }
    var descriptionIncludingEdges: String { get }
}

public func < <V : VertexProtocol>(lhs: V, rhs: V) -> Bool {
    return lhs.hashValue < rhs.hashValue
}

public struct Vertex : VertexProtocol, CustomStringConvertible {
    public var edges = [Int:Int]()
    public var hashValue: Int
    var name: String
    
    public init(value: Int, name: String = "Vertex") {
        self.hashValue = value
        self.name = name
    }
    
    public func getWeight(_ vertex: Int) -> Int? {
        return edges[vertex]
    }
    
    mutating public func addEdge(_ vertex: Int, weight: Int = 1) {
        edges[vertex] = weight
    }
    
    mutating public func removeEdge(_ vertex: Int) {
        edges.removeValue(forKey: vertex)
    }
    
    public mutating func removeAllEdges() {
        edges = [:]
    }
    
    public var description: String {
        return "\(name): \(hashValue)"
    }
    
    public var descriptionIncludingEdges: String {
        return description + ", edges to: \(Array(edges.sorted { $0.key < $1.key }))"
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
    
    public func depthFirstSearch(start: V) -> [V] {
        return []
    }
    
}

public protocol GraphProtocol {
    associatedtype V : VertexProtocol
    var vertices: [Int:V] { get }
}

extension GraphProtocol {
    public func djikstra(start: V, end: V) -> [Int] {
        assert(vertices[start.hashValue] != nil && vertices[end.hashValue] != nil, "Start or end is not part of graph.")
        guard start != end else { return [] }
        var visited = [Int:(weight: Int, last: V)]()
        djikstraRec(start: start, end: end, weights: 0, visited: &visited)
        let v = visited.sorted { $0.key < $1.key }
        print("visited:")
        for i in v {
            print("\t", i)
        }
        var result = [Int]()
        var current = end.hashValue
        var next = Optional(end)?.hashValue
        repeat {
            current = next!.hashValue
            next = visited[current]?.last.hashValue
            result.append(current)
            if next == nil && current != start.hashValue { return [] }
        } while current != start.hashValue
        return result.reversed()
    }
    
    private func djikstraRec(start: V, end: V, weights: Int, visited: inout [Int:(weight: Int, last: V)]) {
        // print(start.hashValue)
        for v in start.edges.sorted(by: { $0.key < $1.key }) {
            let weightAfterEdge = weights + v.value
            // print(start.hashValue, " -?-> ", v.key, " with weight: ", weightAfterEdge)
            if let existingWeight = visited[v.key]?.weight {
                if weightAfterEdge < existingWeight {
                    visited[v.key] = (weight: weightAfterEdge, last: start)
                } else { continue }
            } else { visited[v.key] = (weight: weightAfterEdge, last: start) }
            // print("\tvisited[\(v.key)] =", visited[v.key]!)
            djikstraRec(start: vertices[v.key]!, end: end, weights: weightAfterEdge, visited: &visited)
        }
    }
    
    public func bellmanFord(start: V, end: V) -> [Int] {
        assert(vertices[start.hashValue] != nil && vertices[end.hashValue] != nil, "Start or end is not part of graph.")
        guard start != end else { return [] }
        var visited = [Int:(weight: Int, last: V)]()
        bellmanFordRec(start: start, end: end, weights: 0, visited: &visited)
        let v = visited.sorted { $0.key < $1.key }
        print("visited:")
        for i in v {
            print("\t", i)
        }
        var result = [Int]()
        var current = end.hashValue
        var next = Optional(end)?.hashValue
        repeat {
            current = next!.hashValue
            next = visited[current]?.last.hashValue
            result.append(current)
            if next == nil && current != start.hashValue { return [] }
        } while current != start.hashValue
        return result.reversed()
    }
    
    private func bellmanFordRec(start: V, end: V, weights: Int, visited: inout [Int:(weight: Int, last: V)]) {
        // print(start.hashValue)
        for v in start.edges.sorted(by: { $0.key < $1.key }) {
            let weightAfterEdge = weights + v.value
            // print(start.hashValue, " -?-> ", v.key, " with weight: ", weightAfterEdge)
            if let existingWeight = visited[v.key]?.weight {
                if weightAfterEdge < existingWeight {
                    visited[v.key] = (weight: weightAfterEdge, last: start)
                } else { continue }
            } else { visited[v.key] = (weight: weightAfterEdge, last: start) }
            // print("\tvisited[\(v.key)] =", visited[v.key]!)
            bellmanFordRec(start: vertices[v.key]!, end: end, weights: weightAfterEdge, visited: &visited)
        }
    }
    
}


func print<K>(unwrapping: K?) {
    print(unwrapping != nil ? "\(unwrapping!)" : "nil")
}

func print<K>(unwrapping: [K?]) {
    for i in unwrapping.indices {
        print(unwrapping: unwrapping[i])
    }
}
