//
//  Graph_Coloring.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 07.04.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

/*
extension Graph {
    
    var complete: Bool {
        let vertexCount = vertices.count
        for v in vertices {
            guard self[v].count == vertexCount else { return false }
        }
        return true
    }
    
    var chromaticNonAdjacentVertices: (Int, Int)? {
        let vertices = self.vertices
        
        var firstPair: (Int, Int)? = nil
        
        func getNeighborHoodCount(of pair: (Int, Int)) -> Int {
            
            let startNeighbors = Set(self[pair.0].map { $0.end })
            let endNeighbors = Set(self[pair.1].map { $0.end })
            
            return startNeighbors.intersection(endNeighbors).count
        }
        
        for start in vertices {
            
            for end in vertices {
                guard self[start, end] == nil else { continue }
                guard let fp = firstPair else { firstPair = (start, end); continue }
                guard getNeighborHoodCount(of: (start, end)) >= getNeighborHoodCount(of: fp) else { continue }
                
                
            }
            
            
        }
        
        
        
        
    }
    
    var chromaticNumber: Int? {
        
        var g = self
        
        while true {
            guard !g.complete else { return g.vertices.count }
            
            
        }
        
        
        
        
        return 0
        
    }
    
    
}
*/
