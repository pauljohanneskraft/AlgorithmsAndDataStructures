//
//  Concurrency.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 08.04.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import Foundation

public class Atomic<T> {
    private var sem = DispatchSemaphore(value: 1)
    public init(initialValue: T) {
        self.value = initialValue
    }
    public private(set) var value: T
    public func operate<R>(_ fun: (inout T) throws -> R) rethrows -> R {
        sem.wait()
        defer { sem.signal() }
        return try fun(&value)
    }
}

extension Atomic: CustomStringConvertible {
    public var description: String { return "\(self.value)" }
}
