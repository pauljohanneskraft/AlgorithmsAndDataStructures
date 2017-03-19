//
//  Graph_Pathfinding.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 19.03.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import Foundation

extension Graph {
    
    public func djikstra(start: Int) -> [Int:(weight: Int, last: Int)] {
        var visited = [Int:(weight: Int, last: Int)]()
        
        djikstraRec(start: start, weights: 0, visited: &visited)
        
        return visited
    }
    
    public func djikstra(start: Int, end: Int) -> [Int] {
        let visited = djikstra(start: start)
        
        var result = [Int]()
        var current = end
        var next = Optional(end)
        repeat {
            current = next!
            next = visited[current]?.last
            result.append(current)
            if next == nil && current != start { return [] }
        } while current != start
        return result.reversed()
    }
    
    private func djikstraRec(start: Int, weights: Int, visited: inout [Int:(weight: Int, last: Int)]) {
        // print(start.hashValue)
        for v in self[start].sorted(by: { $0.weight < $1.weight }) {
            let weightAfterEdge = weights + v.weight
            // print(start.hashValue, " -?-> ", v.key, " with weight: ", weightAfterEdge)
            if let existingWeight = visited[v.end]?.weight {
                if weightAfterEdge < existingWeight {
                    visited[v.end] = (weight: weightAfterEdge, last: start)
                } else { continue }
            } else { visited[v.end] = (weight: weightAfterEdge, last: start) }
            // print("\tvisited[\(v.key)] =", visited[v.key]!)
            djikstraRec(start: v.end, weights: weightAfterEdge, visited: &visited)
        }
    }
}

extension Graph {
    
    public func bellmanFord(start: Int) -> [Int:(weight: Int, last: Int)] {
        var visited = [Int:(weight: Int, last: Int)]()
        
        let edges = self.edges
        guard edges.count > 0 else { return [:] }
        visited[start] = (weight: 0, last: start)
        for _ in vertices {
            for e in edges {
                if var newWeight = visited[e.start]?.weight {
                    newWeight += e.weight
                    if let oldWeight = visited[e.end]?.weight {
                        if newWeight < oldWeight {
                            visited[e.end] = (weight: newWeight, last: e.start)
                        }
                    } else { visited[e.end] = (weight: newWeight, last: e.start) }
                }
            }
        }
        // print("done with djikstra")
        for e in edges {
            if var newWeight = visited[e.start]?.weight {
                if newWeight != Int.min { newWeight += e.weight
                    if let oldWeight = visited[e.end]?.weight {
                        if newWeight < oldWeight {
                            infect(e.start, visited: &visited)
                        }
                    } else { assert(false) }
                }
            }
        }
        // print("done with bellmanFord")
        return visited
    }
    
    private func infect(_ start: Int,  visited: inout [Int:(weight: Int, last: Int)]) {
        // print("infected \(start)")
        visited[start] = (weight: Int.min, last: visited[start]!.last)
        for v in self[start] {
            if visited[v.end]?.weight != Int.min {
                visited[v.end] = (weight: Int.min, last: start)
                infect(v.end, visited: &visited)
            }
        }
    }
}


public extension Graph {
    public func bestFirst(start: Int, end: Int, heuristic: @escaping (Int) -> Int) -> [Int]? {
        
        var edgeStart = start
        var candidates = Set([start])
        var visited = Set<Int>()
        var predecessor = [edgeStart : edgeStart]
        while true {
            guard let edgeS = candidates.min(by: { heuristic($0) < heuristic($1) }) else { return nil }
            // print("visiting", edgeS)
            edgeStart = edgeS
            visited.insert(edgeStart)
            candidates.remove(edgeS)
            if edgeStart == end { break }
            for c in self[edgeStart].filter( { !(visited.contains($0.end)) && !(candidates.contains($0.end)) } ) {
                candidates.insert(c.end)
                predecessor[c.end] = edgeStart
            }
        }
        
        var path = [edgeStart]
        
        while edgeStart != start {
            edgeStart = predecessor[edgeStart]!
            path.append(edgeStart)
        }
        
        return path.reversed()
    }
}

public extension Graph {
    public func aStar(start: Int, end: Int, heuristic: @escaping (Int) -> Int) -> [Int]? {
        
        var edgeStart = start
        var candidates = Set([start])
        var visited = Set<Int>()
        var maxCost = Int.max
        var nodeInfo = [Int : (predecessor: Int, cost: Int)]()
        nodeInfo[edgeStart] = (predecessor: edgeStart, cost: 0)
        while !candidates.isEmpty {
            guard let edgeS = candidates.min(by: { nodeInfo[$0]!.cost + heuristic($0) < heuristic($1) + nodeInfo[$1]!.cost }) else { return nil }
            edgeStart = edgeS
            visited.insert(edgeStart)
            candidates.remove(edgeS)
            let edgeStartInfo = nodeInfo[edgeStart]!
            guard edgeStart != end else { maxCost = edgeStartInfo.cost; continue }
            for c in self[edgeStart].filter( { !(candidates.contains($0.end)) } ) {
                let cost = edgeStartInfo.cost + self[edgeStart, c.end]!
                guard cost < maxCost else { continue }
                if let ni = nodeInfo[c.end], ni.cost <= cost {} else {
                    candidates.insert(c.end)
                    nodeInfo[c.end] = (predecessor: edgeStart, cost: cost)
                }
                
            }
        }
        edgeStart = end
        var path = [edgeStart]
        
        while edgeStart != start {
            edgeStart = nodeInfo[edgeStart]!.predecessor
            path.append(edgeStart)
        }
        
        return path.reversed()
    }
}
