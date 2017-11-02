//
//  Graph_Algorithms.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 17.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

extension Graph {
	
	/*
	source:
		Title: Der Hierholzer Algorithmus
		Authors: Mark J. Becker, Wolfgang F. Riedl; Technische Universität München
		Link: https://www-m9.ma.tum.de/graph-algorithms/hierholzer
	*/
    
    private func findEndpoints() -> (start: Int, end: Int)? {
        var endpoints = [Int]()
        for v in vertices {
            let sv = self[v]
            if sv.count % 2 == 1 { endpoints.append(v) }
        }
        guard endpoints.count == 2 else {
            guard endpoints.count == 1 else {
                guard let f = vertices.first else { return nil }
                return (f, f)
            }
            return (endpoints[0], endpoints[0])
        }
        return (endpoints[0], endpoints[1])
    }
	
	public func hierholzer() -> [Int]? {
        
        guard let (startv, end) = findEndpoints() else { print("ENDPOINTS!"); return nil }
        
        guard let tours = hierholzer_rec(startv: startv, end: end, didSwap: false), tours.count > 0 else { return nil }
        
		return combining(tours: tours)
	}
    
    private func hierholzer_rec(startv: Int, end: Int, didSwap: Bool) -> [[Int]]? {
        var subtour = [Int]()
        var tours = [[Int]]()
        var remainingEdges: [Int: Set<Int>] = [:]
        for v in vertices { remainingEdges[v] = Set(self[v].map { $0.end }) }
        var visited: [Int: Set<Int>] = [:]
        var start = startv
        
        repeat {
            subtour = [start]
            var current = start
            // print("new subtour starting at \(start) with remainingEdges:", remainingEdges)
            repeat {
                // print(current, subtour, remainingEdges)
                guard let next = remainingEdges[current]?
                    .min(by: { edgeStart, _ in self[edgeStart, current] == nil }) else {
                        // print(tours, subtour, remainingEdges)
                        // print(self)
                        
                        if end != startv {
                            // print("swaps")
                            guard !didSwap else { return nil }
                            return hierholzer_rec(startv: end, end: startv, didSwap: true)
                        }
                        // print("swapping?")
                        return nil
                }
                // print("\tvisiting \(end)")
                
                remainingEdges[current]!.remove(next)
                _ = remainingEdges[next]?.remove(current)
                if remainingEdges[current]!.isEmpty {
                    remainingEdges[current] = nil
                }
                if remainingEdges[next]?.isEmpty ?? false {
                    remainingEdges[next] = nil
                }
                
                if visited[current] != nil {
                    visited[current]!.insert(next)
                } else {
                    visited[current] = [next]
                }
                if visited[next] != nil {
                    visited[next]!.insert(current)
                } else {
                    visited[next] = [current]
                }
                
                subtour.append(next)
                current = next
                
            } while !remainingEdges.isEmpty && (current != end || current != start)
            tours.append(subtour)
            start = remainingEdges.keys.first ?? start
        } while !remainingEdges.isEmpty
        return tours
    }
    
    private func combining(tours: [[Int]]) -> [Int]? {
        var tours = tours
        var tour = tours.remove(at: 0)
        
        var didNotWork = 0
        // print("tours", tours, "tour", tour)
        while !tours.isEmpty {
            guard didNotWork < tours.count else { print("failed to assemble"); return nil }
            var t = tours.first!
            // print(tours, tour, t)
            if t[t.startIndex] == t[t.endIndex - 1] {
                if var index = tour.indices.first(where: { t.contains(tour[$0]) }) {
                    let i = t.indices.first(where: { tour[index] == t[$0] })!
                    // print(tour, t, "contains", tour[index], "at", i)
                    _ = t.popLast()
                    for _ in 0..<i { t.append(t.remove(at: 0)) }
                    for n in t {
                        tour.insert(n, at: index)
                        index += 1
                    }
                    didNotWork = 0
                    tours.remove(at: 0)
                    // print(t, "join successful \(tours)")
                } else {
                    didNotWork += 1
                    tours.append(tours.remove(at: 0))
                }
            } else if tours.count == 1 {
                // print("did enter")
                tour.remove(at: 0)
                var i = 0
                while tour.last! != t.first! {
                    guard i < tour.count else { print("failed to assemble"); return nil }
                    i += 1
                    tour.append(tour.remove(at: 0))
                }
                tours.remove(at: 0)
                tour.remove(at: tour.endIndex - 1)
                tour.insert(t.first!, at: 0)
                tour.append(contentsOf: t)
            } else {
                didNotWork += 1
                tours.append(tours.remove(at: 0))
            }
            
        }
        return tour
    }
	
}

extension Graph {
	
    public func nearestNeighbor(start: Int, lastPath finish: Bool = true) -> (path: [Int], distance: Int)? {
		var remaining = vertices
		var route = [start]
		var current = start
        remaining.remove(start)
		var length = 0
        for _ in 1..<vertices.count {
            guard let v = self[current]
                .filter({ remaining.contains($0.end) })
                .min(by: { $0.weight < $1.weight }) else {
                    return nil
            }
            current = v.end
            route.append(current)
            remaining.remove(current)
            length += v.weight

        }
        guard finish else { return (route, length) }
        guard let lastPath = self[route.last!, start] else { return nil }
        route.append(start)
        return (route, length + lastPath)
	}
	
}

extension Graph {
	
    /*
	public func kruskal() -> [(start: Int, end: Int, weight: Int)]? {
        // guard !directed else { return nil }
        
        func hasCircle(from: Int, visited: Set<Int> = [], edges: [Int: Set<Int>]) -> Bool {
            var visited = visited
            var edges = edges
            for v in edges[from]! {
                // edges[v]!.remove(from)
                // print("\tlooking at (\(from),\(v))", visited)
                guard !visited.contains(v) else { return true }
                visited.insert(v)
                guard !hasCircle(from: v, visited: visited, edges: edges) else { return true }
                visited.remove(v)
                // edges[v]!.insert(from)
            }
            return false
        }
        
        var spanningTree = [(start: Int, end: Int, weight: Int)]()
        var visited = [Int:Set<Int>]()
        
        for v in vertices { visited[v] = Set<Int>() }
        
        for e in edges.sorted(by: { $0.weight < $1.weight }) {
            // print("checking out \(e)")
            spanningTree.append(e)
            visited[e.start    ]!.insert(e.end        )
            // visited[e.end    ]!.insert(e.start    )
            if hasCircle(from: e.start, edges: visited) || hasCircle(from: e.end, edges: visited) {
                // print("removing \(e)")
                spanningTree.removeLast()
                visited[e.start]!.remove(e.end)
            }
        }
        return spanningTree
    }
 */
}

#if !os(Linux)

import Foundation

public extension Graph {
    // swiftlint:disable function_body_length function_parameter_count
    
    public func bellmanHeldKarp(start: Int) -> (path: [Int], distance: Int)? {
        let semaphore = DispatchSemaphore(value: 1)
        
        guard var nearestNeighbor = self.nearestNeighbor(start: start, lastPath: true) else { return nil }
        var bestAnswer = nearestNeighbor // { didSet { print(bestAnswer) } }
        
        func heldKarp_rec(
 from: Int, start: Int, path visited: [Int],
 visit: Set<Int>, distance: Int, maxDistance: Int) -> Int {
            guard distance < maxDistance else { return maxDistance }
            let visited = visited + [start]
            var visit = visit
            _ = visit.remove(start)
            guard !visit.isEmpty else {
                if let lastPath = self[start, from] {
                    let fullDistance = distance + lastPath
                    if fullDistance < maxDistance {
                        let result = (path: visited + [from], distance: fullDistance)
                        semaphore.wait()
                        defer { semaphore.signal() }
                        if result.distance < bestAnswer.distance {
                            bestAnswer = result
                        }
                        return bestAnswer.distance
                    }
                    
                }
                return maxDistance
            }
            var minDistance = maxDistance
            
            let filtered = visit.filter({
                guard let w = self[start, $0] else {
                    return false
                }
                return distance + w < minDistance
            })
            
            let filteredAndSorted = filtered.sorted(by: { self[start, $0]! < self[start, $1]! })
            // print(visit.count)
            // print(start, visit.sorted(), visited, distance)
            for v in filteredAndSorted {
                // print(minDistance)
                // guard v != start else { continue }
                if let edge_weight = self[start, v] {
                    visit.remove(v)
                    let m = heldKarp_rec(
 from: from, start: v, path: visited,
 visit: visit, distance: edge_weight + distance, maxDistance: minDistance)
                    minDistance = max(minDistance, m)
                    visit.insert(v)
                }
            }
            
            return minDistance
        }
        
        let queue = DispatchQueue(label: "heldKarp", attributes: .concurrent)
        let group = DispatchGroup()
        var vs = vertices
        vs.remove(start)
        // print("start", start, vs.sorted())
        var minDistance = nearestNeighbor.distance
        var i = 0
        for e in self[start].sorted(by: { $0.weight < $1.weight }) {
            i += 1
            guard e.end != start else { continue }
            queue.async(group: group) {
                let m = heldKarp_rec(
 from: start, start: e.end, path: [start],
 visit: vs, distance: e.weight, maxDistance: minDistance)
                semaphore.wait()
                minDistance = max(minDistance, m)
                semaphore.signal()
                // print("e.end \(e.end) done")
            }
            if i % 5 == 4 {
                group.wait()
                semaphore.wait()
                minDistance = bestAnswer.distance
                semaphore.signal()
            }
        }
        group.wait()
        // print("answers", answers)
        return bestAnswer
    }
}
#endif
