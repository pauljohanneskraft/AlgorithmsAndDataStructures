//
//  StableMarriageProblem.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 14.02.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public class Proposer <Data> {
    public var data: Data
    public var fiancee: Proposer<Data>?
    public var candidates = [Proposer<Data>]()
    var candidateIndex = 0
    
    public init(data: Data) { self.data = data }
    
    func rank(of candidate: Proposer<Data>) -> Int {
        return candidates.index(where: { candidate === $0 }) ?? candidates.count
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
    
    func engage(to guy: Proposer<Data>) {
        if let f = guy.fiancee { f.fiancee = nil }
        guy.fiancee = self
        if let f = self.fiancee { f.fiancee = nil }
        self.fiancee = guy
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

public func stableMarriageProblem<D>(proposers guys: [Proposer<D>]) {
    var done = true
    repeat {
        done = true
        for guy in guys where guy.fiancee == nil {
            done = false
            if let gal = guy.nextCandidate() {
                if gal.prefers(guy) {
                    guy.engage(to: gal)
                }
            }
        }
    } while !done
}
