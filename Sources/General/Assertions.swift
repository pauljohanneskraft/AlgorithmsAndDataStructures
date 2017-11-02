//
//  Assertions.swift
//  Algorithms & Data structuresPackageDescription
//
//  Created by Paul Kraft on 01.11.17.
//

func assertEqual<E: Equatable>(_ exp1: E, _ exp2: E) {
    assert(exp1 == exp2, "\(exp1) != \(exp2)")
}

func assertNotNil<W>(_ opt: W?) {
    assert(opt != nil, "Found nil")
}
