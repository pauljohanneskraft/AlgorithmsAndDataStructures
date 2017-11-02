//
//  Graph_Pathfinding.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 19.03.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import Foundation

// swiftlint:disable trailing_whitespace

extension Graph {
    
    public func djikstra(start: Int) -> [Int:(weight: Int, predecessor: Int)] {
        
        var edgeStart = start
        var candidates = BinomialHeap<(key: Int, value: Int)>(order: { $0.key < $1.key })
        candidates.push((key: 0, value: start))
        var nodeInfo = [Int: (weight: Int, predecessor: Int)]()
        nodeInfo[edgeStart] = (weight: 0, predecessor: edgeStart)
        var edgeStartInfo = nodeInfo[edgeStart]!
        while !candidates.isEmpty {
            guard let edgeS = candidates.pop()?.value else { return nodeInfo }
            edgeStart = edgeS
            edgeStartInfo = nodeInfo[edgeStart]!
            for c in self[edgeStart] {
                let cost = edgeStartInfo.weight + c.weight
                if let ni = nodeInfo[c.end], ni.weight <= cost {} else {
                    candidates.push((key: cost, value: c.end))
                    nodeInfo[c.end] = (weight: cost, predecessor: edgeStart)
                }
            }
        }
        
        return nodeInfo
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
    
    // swiftlint:disable:next cyclomatic_complexity
    public func concurrentDijkstra(start: Int) -> [Int: Atomic<(weight: Int, predecessor: Int)>] {
        
        let candidates = Atomic(initialValue: BinomialHeap<(key: Int, value: Int)>(order: { $0.key < $1.key }))
        candidates.operate { $0.push((key: 0, value: start)) }
        var nodeInfo = [Int: Atomic<(weight: Int, predecessor: Int)>]()
        
        for v in vertices {
            nodeInfo[v] = Atomic(initialValue: (weight: Int.max, predecessor: v))
        }
        
        nodeInfo[start] = Atomic(initialValue: (weight: 0, predecessor: start))
        
        let concQueue   = DispatchQueue(label: "ConcurrentDijkstra", attributes: .concurrent)
        let group       = DispatchGroup()
        
        for c in self[start]
            where (nodeInfo[c.end]?.value.weight ?? Int.min) >= c.weight {
            candidates.operate { $0.push((key: c.weight, value: c.end)) }
            nodeInfo[c.end]!.operate { $0 = (weight: c.weight, predecessor: start) }
        }
        
        for _ in 0..<3 {
            concQueue.async(group: group) {
                while let edgeStart = candidates.operate({ $0.pop()?.value }) {
                    
                    nodeInfo[edgeStart]!.operate { edgeStartInfo in
                        for c in self[edgeStart] {
                            let cost = edgeStartInfo.weight < Int.max ? edgeStartInfo.weight + c.weight : Int.max
                            guard nodeInfo[c.end]!.value.weight > cost else { continue }
                            
                            nodeInfo[c.end]!.operate({ cEndInfo in
                                guard cEndInfo.weight > cost else { return }
                                candidates.operate { $0.push((key: cost, value: c.end)) }
                                cEndInfo = (weight: cost, predecessor: edgeStart)
                                
                            })
                        }
                    }
                }
            }
        }
        
        while let edgeStart = candidates.operate({ $0.pop()?.value }) {
            
            nodeInfo[edgeStart]!.operate { edgeStartInfo in
                for c in self[edgeStart] {
                    let cost = edgeStartInfo.weight < Int.max ? edgeStartInfo.weight + c.weight : Int.max
                    guard nodeInfo[c.end]!.value.weight > cost else { continue }
                    
                    nodeInfo[c.end]!.operate({ cEndInfo in
                        guard cEndInfo.weight > cost else { return }
                        candidates.operate { $0.push((key: cost, value: c.end)) }
                        cEndInfo = (weight: cost, predecessor: edgeStart)
                        
                    })
                }
            }
        }
        
        group.wait()
        
        return nodeInfo
    }
    
    public func concurrentDijkstra(start: Int, end: Int) -> [Int]? {
        let visited = concurrentDijkstra(start: start)
        // print("done with concurrency")
        var result = [Int]()
        var current = end
        var next = end
        repeat {
            current = next
            guard let nextOne = visited[current]?.value.predecessor else {
                return nil
            }
            next = nextOne
            result.append(current)
            guard current != start, !result.contains(next) else {
                return visited.keys.filter({ visited[$0]!.value.weight < Int.max })
            }
        } while current != start
        // print("done")
        return result.reversed()
    }
    
}

extension Graph {
    
    public func bellmanFord(start: Int) -> [Int: (weight: Int, predecessor: Int)] {
        var visited = [Int: (weight: Int, predecessor: Int)]()
        
        let edges = self.edges
        guard edges.count > 0 else { return [:] }
        visited[start] = (weight: 0, predecessor: start)
        for _ in vertices {
            for e in edges {
                if var newWeight = visited[e.start]?.weight {
                    newWeight += e.weight
                    let oldWeight = visited[e.end]?.weight ?? Int.max
                    if newWeight < oldWeight {
                        visited[e.end] = (weight: newWeight, predecessor: e.start)
                    }
                }
            }
        }
        // print("done with djikstra")
        for e in edges {
            if var newWeight = visited[e.start]?.weight, newWeight != Int.min {
                newWeight += e.weight
                guard let oldWeight = visited[e.end]?.weight else {
                    assert(false)
                    return [:]
                }
                if newWeight < oldWeight {
                    infect(e.start, visited: &visited)
                }
            }
        }
        // print("done with bellmanFord")
        return visited
    }
    
    private func infect(_ start: Int, visited: inout [Int:(weight: Int, predecessor: Int)]) {
        // print("infected \(start)")
        visited[start] = (weight: Int.min, predecessor: visited[start]!.predecessor)
        for v in self[start] where visited[v.end]?.weight != Int.min {
            visited[v.end] = (weight: Int.min, predecessor: start)
            infect(v.end, visited: &visited)
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
        
        var edgeStart: Int? = start
        var candidates = BinomialHeap<(key: Int, value: Int)>(order: { $0.key < $1.key })
        candidates.push((key: heuristic(start), value: start))
        var candidateSet = Set<Int>()
        var predecessor = [edgeStart!: edgeStart!]
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
        var candidates = BinomialHeap<(key: Int, value: Int)>(order: { $0.key < $1.key })
        candidates.push((key: heuristic(start), value: start))
        var nodeInfo = [Int: (predecessor: Int, cost: Int)]()
        nodeInfo[start] = (predecessor: start, cost: 0)
        var edgeStartInfo = (predecessor: start, cost: 0)
        while let edgeStart = candidates.pop()?.value, edgeStart != end {
            edgeStartInfo = nodeInfo[edgeStart]!
            for c in self[edgeStart] {
                let cost = edgeStartInfo.cost + c.weight
                if nodeInfo[c.end] == nil {
                    candidates.push((key: cost + heuristic(c.end), value: c.end))
                    nodeInfo[c.end] = (predecessor: edgeStart, cost: cost)
                }
            }
        }
        
        var edgeStart = end
        var path = [edgeStart]
        
        while edgeStart != start {
            guard let pred = nodeInfo[edgeStart]?.predecessor else { return nil }
            edgeStart = pred
            path.append(edgeStart)
        }
        
        return path.reversed()
    }
}

extension Graph {
    
    public func fringeSearch(start: Int, end: Int) -> [Int]? {
        // swiftlint:disable:next todo
        return [] // FIXME: Implement FringeSearch
    }
    
}
