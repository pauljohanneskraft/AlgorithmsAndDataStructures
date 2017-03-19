//
//  SmartBufferedLazyList.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 17.03.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct SmartBufferedLazyList<Element> {
    fileprivate(set) var buffer : Buffer<Element> // Buffer is defined in BufferedLazyList.swift
    public init(start: Element, bufferDistance: Int = 5, rule: @escaping (Element) -> Element) {
        self.buffer = Buffer<Element>(start: start)
        self.rule = rule
        self.bufferHoleSize = bufferDistance
    }
    fileprivate let bufferHoleSize : Int
    fileprivate(set) var rule : (Element) -> Element
}

extension SmartBufferedLazyList : Collection {
    public mutating func reduceBufferSize(to: Int) {
        let endIndex = to < 1 ? 1 : to
        guard buffer.count > endIndex else { return }
        self.buffer = Buffer<Element>(value: Array(buffer[0..<endIndex]))!
    }
    
    public var bufferCount: Int { return buffer.count }
    
    public mutating func clearBuffer() {
        self.buffer = Buffer<Element>(start: self.buffer.first)
    }
    
    public func lazymap(_ transform: @escaping (Element) -> Element) -> SmartBufferedLazyList<Element> {
        let rule = self.rule
        return SmartBufferedLazyList<Element>(start: buffer.first) { transform(rule($0)) }
    }
    
    public func get(first: UInt) -> [Element] {
        var elems = [Element]()
        var curr = buffer.first
        for _ in 0..<first {
            elems.append(curr)
            curr = rule(curr)
        }
        return elems
    }
    
    public subscript(index: Int) -> Element {
        get {
            guard index / bufferHoleSize >= buffer.count else {
                var curr = buffer[index/bufferHoleSize]
                for _ in 0..<(index % bufferHoleSize) { curr = rule(curr) }
                // print(index, curr)
                return curr
            }
            
            for _ in (buffer.count - 1)..<(index / bufferHoleSize) {
                var curr = buffer.last
                for _ in 0..<bufferHoleSize {
                    curr = rule(curr)
                }
                buffer.append(curr)
            }
            
            // print(buffer.count, "after index")
            
            var curr = buffer.last
            for _ in 0..<(index % bufferHoleSize) { curr = rule(curr) }
            // print(index, curr)
            return curr
        }
    }
    
    public func index(after: Int) -> Int { return after + 1 }
    
    public var startIndex : Int { return 0 }
    
    public var endIndex : Int { return Int.max }
    
    public var count : Int { return Int.max }
    
    public var first : Element { return buffer.first }
}
