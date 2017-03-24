//
//  Graph_Pathfinding.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 19.03.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import Foundation

extension Graph {
    
    public func djikstra(start: Int) -> [Int:(weight: Int, predecessor: Int)] {
        var visited = [Int:(weight: Int, predecessor: Int)]()
        
        func djikstraRec(start: Int, weights: Int) {
            // print(start.hashValue)
            for v in self[start].sorted(by: { $0.weight < $1.weight }) {
                let weightAfterEdge = weights + v.weight
                // print(start.hashValue, " -?-> ", v.key, " with weight: ", weightAfterEdge)
                if let existingWeight = visited[v.end]?.weight {
                    if weightAfterEdge < existingWeight {
                        visited[v.end] = (weight: weightAfterEdge, predecessor: start)
                    } else { continue }
                } else { visited[v.end] = (weight: weightAfterEdge, predecessor: start) }
                // print("\tvisited[\(v.key)] =", visited[v.key]!)
                djikstraRec(start: v.end, weights: weightAfterEdge)
            }
        }
        
        djikstraRec(start: start, weights: 0)
        
        return visited
    }
    
    public func djikstra(start: Int, end: Int) -> [Int]? {
        let visited = djikstra(start: start)
        
        var result = [Int]()
        var current = end
        var next = Optional(end)
        repeat {
            current = next!
            next = visited[current]?.predecessor
            result.append(current)
            if next == nil && current != start { return nil }
        } while current != start
        return result.reversed()
    }
    
    
}

extension Graph {
    
    public func bellmanFord(start: Int) -> [Int:(weight: Int, predecessor: Int)] {
        var visited = [Int:(weight: Int, predecessor: Int)]()
        
        let edges = self.edges
        guard edges.count > 0 else { return [:] }
        visited[start] = (weight: 0, predecessor: start)
        for _ in vertices {
            for e in edges {
                if var newWeight = visited[e.start]?.weight {
                    newWeight += e.weight
                    if let oldWeight = visited[e.end]?.weight {
                        if newWeight < oldWeight {
                            visited[e.end] = (weight: newWeight, predecessor: e.start)
                        }
                    } else { visited[e.end] = (weight: newWeight, predecessor: e.start) }
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
    
    private func infect(_ start: Int,  visited: inout [Int:(weight: Int, predecessor: Int)]) {
        // print("infected \(start)")
        visited[start] = (weight: Int.min, predecessor: visited[start]!.predecessor)
        for v in self[start] {
            if visited[v.end]?.weight != Int.min {
                visited[v.end] = (weight: Int.min, predecessor: start)
                infect(v.end, visited: &visited)
            }
        }
    }
    
    public func bellmannFord(start: Int, end: Int) -> [Int]? {
        let visited = bellmanFord(start: start)
        
        var result = [Int]()
        var current = end
        var next = Optional(end)
        repeat {
            current = next!
            next = visited[current]?.predecessor
            result.append(current)
            if next == nil && current != start { return nil }
        } while current != start
        return result.reversed()
    }
}


public extension Graph {
    public func bestFirst(start: Int, end: Int, heuristic: @escaping (Int) -> Int) -> [Int]? {
        
        var edgeStart : Int? = start
        var candidates = BinaryMaxHeap<(key: Int, value: Int)>(array: [(key: heuristic(start), value: start)], order: { a, b in a.key > b.key })
        var candidateSet = Set<Int>()
        var predecessor = [edgeStart! : edgeStart!]
        while true {
            edgeStart = candidates.pop()?.value
            guard edgeStart != end && edgeStart != nil else {
                guard edgeStart == end else { return nil }
                break
            }
            for c in self[edgeStart!] {
                guard !(candidateSet.contains(c.end)) else { continue }
                candidateSet.insert(c.end)
                candidates.push((key: heuristic(c.end), value: c.end))
                predecessor[c.end] = edgeStart
            }
        }
        edgeStart = end
        
        var path = [end]
        
        while edgeStart != start {
            guard let pred = predecessor[edgeStart!] else { return nil }
            edgeStart = pred
            path.append(edgeStart!)
        }
        
        return path.reversed()
    }
}

public extension Graph {
    public func aStar(start: Int, end: Int, heuristic: @escaping (Int) -> Int) -> [Int]? {
        
        var edgeStart = start
        var candidates = BinaryMaxHeap<(key: Int, value: Int)>(array: [(key: heuristic(start), value: start)], order: { a, b in a.key > b.key })
        var nodeInfo = [Int : (predecessor: Int, cost: Int)]()
        nodeInfo[edgeStart] = (predecessor: edgeStart, cost: 0)
        var edgeStartInfo = nodeInfo[edgeStart]!
        while !candidates.isEmpty {
            guard let edgeS = candidates.pop()?.value else { return nil }
            guard edgeS != end else { break }
            edgeStart = edgeS
            edgeStartInfo = nodeInfo[edgeStart]!
            for c in self[edgeStart] {
                let cost = edgeStartInfo.cost + self[edgeStart, c.end]!
                if let ni = nodeInfo[c.end], ni.cost <= cost {} else {
                    candidates.push((key: cost + heuristic(c.end), value: c.end))
                    nodeInfo[c.end] = (predecessor: edgeStart, cost: cost)
                }
            }
        }
        
        edgeStart = end
        var path = [edgeStart]
        
        while edgeStart != start {
            guard let pred = nodeInfo[edgeStart]?.predecessor else { return nil }
            edgeStart = pred
            path.append(edgeStart)
        }
        
        return path.reversed()
    }
}
