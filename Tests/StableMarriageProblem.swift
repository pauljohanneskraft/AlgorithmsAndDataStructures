//
//  StableMarriageProblem.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 14.02.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import XCTest
import Algorithms_and_Data_structures

class StableMarriageProblem: XCTestCase {

    func testRosettaCodeExample() {
        let abe  = Proposer<String>(data: "Abe");
        let bob  = Proposer<String>(data: "Bob");
        let col  = Proposer<String>(data: "Col");
        let dan  = Proposer<String>(data: "Dan");
        let ed   = Proposer<String>(data: "Ed");
        let fred = Proposer<String>(data: "Fred");
        let gav  = Proposer<String>(data: "Gav");
        let hal  = Proposer<String>(data: "Hal");
        let ian  = Proposer<String>(data: "Ian");
        let jon  = Proposer<String>(data: "Jon");
        let abi  = Proposer<String>(data: "Abi");
        let bea  = Proposer<String>(data: "Bea");
        let cath = Proposer<String>(data: "Cath");
        let dee  = Proposer<String>(data: "Dee");
        let eve  = Proposer<String>(data: "Eve");
        let fay  = Proposer<String>(data: "Fay");
        let gay  = Proposer<String>(data: "Gay");
        let hope = Proposer<String>(data: "Hope");
        let ivy  = Proposer<String>(data: "Ivy");
        let jan  = Proposer<String>(data: "Jan");
        
        abe.candidates  = [abi, eve, cath, ivy, jan, dee, fay, bea, hope, gay];
        bob.candidates  = [cath, hope, abi, dee, eve, fay, bea, jan, ivy, gay];
        col.candidates  = [hope, eve, abi, dee, bea, fay, ivy, gay, cath, jan];
        dan.candidates  = [ivy, fay, dee, gay, hope, eve, jan, bea, cath, abi];
        ed.candidates   = [jan, dee, bea, cath, fay, eve, abi, ivy, hope, gay];
        fred.candidates = [bea, abi, dee, gay, eve, ivy, cath, jan, hope, fay];
        gav.candidates  = [gay, eve, ivy, bea, cath, abi, dee, hope, jan, fay];
        hal.candidates  = [abi, eve, hope, fay, ivy, cath, jan, bea, gay, dee];
        ian.candidates  = [hope, cath, dee, gay, bea, abi, fay, ivy, jan, eve];
        jon.candidates  = [abi, fay, jan, gay, eve, bea, dee, cath, ivy, hope];
        abi.candidates  = [bob, fred, jon, gav, ian, abe, dan, ed, col, hal];
        bea.candidates  = [bob, abe, col, fred, gav, dan, ian, ed, jon, hal];
        cath.candidates = [fred, bob, ed, gav, hal, col, ian, abe, dan, jon];
        dee.candidates  = [fred, jon, col, abe, ian, hal, gav, dan, bob, ed];
        eve.candidates  = [jon, hal, fred, dan, abe, gav, col, ed, ian, bob];
        fay.candidates  = [bob, abe, ed, ian, jon, dan, fred, gav, col, hal];
        gay.candidates  = [jon, gav, hal, fred, bob, abe, col, ed, dan, ian];
        hope.candidates = [gav, jon, bob, abe, ian, dan, hal, ed, col, fred];
        ivy.candidates  = [ian, col, hal, gav, fred, bob, abe, ed, jon, dan];
        jan.candidates  = [ed, hal, gav, abe, bob, jon, col, ian, fred, dan];
        
        let guys = [abe, bob, col, dan, ed, fred, gav, hal, ian, jon];
        let gals = [abi, bea, cath, dee, eve, fay, gay, hope, ivy, jan];
        
        stableMarriageProblem(proposers: guys)
        
        for g in guys {
            print("\(g.data) is engaged to \(g.fiancee!.data)")
        }
        print("Stable = \(isStable(guys: guys, gals: gals))");
    }

}
