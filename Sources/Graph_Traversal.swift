//
//  Graph_Traversal.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 19.03.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import Foundation

extension Graph {
    
    public func depthFirstSearch<E,F>(
        start: Int,
        order: ((end: Int, weight: Int), (end: Int, weight: Int)) -> Bool = { $0.weight < $1.weight },
        onEntry: (Int) throws -> E, onFinish: (Int) throws -> F
        ) rethrows -> (onEntry: [E], onFinish: [F]) {
        
        var visited = Set<Int>()
        return try dfs_rec(start: start, order: order, onEntry: onEntry, onFinish: onFinish, visited: &visited)
    }
    
    private func dfs_rec<E,F>(
        start current: Int,
        order: ((end: Int, weight: Int), (end: Int, weight: Int)) -> Bool,
        onEntry: (Int) throws -> E, onFinish: (Int) throws -> F,
        visited: inout Set<Int>
        ) rethrows -> (onEntry: [E], onFinish: [F]) {
        
        var resultE = [try onEntry(current)]
        var resultF = [F]()
        
        visited.insert(current)
        
        for e in self[current].sorted(by: order) {
            if !visited.contains(e.end) {
                let e = try dfs_rec(start: e.end, order: order, onEntry: onEntry, onFinish: onFinish, visited: &visited)
                resultE.append(contentsOf: e.onEntry)
                resultF.append(contentsOf: e.onFinish)
            }
        }
        
        resultF.append(try onFinish(current))
        
        return (resultE, resultF)
    }
}

extension Graph {
    
    public func breadthFirstSearch<T>(start: Int, _ f: (Int) throws -> T) rethrows -> [T] {
        var visited = [Int:Int]()
        var list = [start]
        var result : [T] = []
        var current : Int
        
        visited[start] = start
        
        while !list.isEmpty {
            current = list.remove(at: 0)
            // print("visiting", current)
            let ends = self[current]
            for e in ends {
                if visited[e.end] == nil {
                    // print(e)
                    list.append(e.end)
                    visited[e.end] = current
                }
            }
            result.append(try f(current))
        }
        return result
    }
}
