//
//  StableMarriageProblem.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 14.02.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import Foundation


public class Proposer <Data> {
    public var data : Data
    public var fiancee : Proposer<Data>? = nil
    public var candidates = [Proposer<Data>]()
    var candidateIndex = 0
    
    public init(data: Data) { self.data = data }
    
    func rank(of cand: Proposer<Data>) -> Int {
        for i in candidates.indices {
            if candidates[i] === cand { return i }
        }
        return candidates.count + 1
    }
    
    func prefers(_ newFiancee: Proposer<Data>) -> Bool {
        if let f = self.fiancee {
            return rank(of: newFiancee) < rank(of: f)
        }
        return true
    }
    
    func nextCandidate() -> Proposer<Data>? {
        if candidateIndex >= candidates.count { return nil }
        let c = candidates[candidateIndex]
        candidateIndex += 1
        return c
    }
    
    func engage(to: Proposer<Data>) {
        if let f =   to.fiancee { f.fiancee = nil }
        to.fiancee = self
        if let f = self.fiancee { f.fiancee = nil }
        self.fiancee = to
    }
}


public func isStable<D>(guys: [Proposer<D>], gals: [Proposer<D>]) -> Bool {
    for i in guys.indices {
        for j in gals.indices {
            if guys[i].prefers(gals[j]) && gals[j].prefers(guys[i]) {
                return false
            }
        }
    }
    return true
}


public func stableMarriageProblem<D>(proposers guys: [Proposer<D>]){
    var done = true
    repeat {
        done = true
        for guy in guys {
            if guy.fiancee == nil {
                done = false
                if let gal = guy.nextCandidate() {
                    if gal.prefers(guy) {
                        guy.engage(to: gal)
                    }
                }
            }
        }
    } while (!done);
    
}
