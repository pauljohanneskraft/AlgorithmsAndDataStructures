//
//  BufferedLazyList.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 17.03.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

import Foundation

class Buffer<Element> { // needs to be class, so that BufferedLazyList is not mutated when accessing data
    convenience init(start: Element) { self.init(value: [start])! }
    init?(value: [Element]) {
        guard value.count > 0 else { return nil }
        self.value = value
    }
    
    private var value: [Element] = []
    
    var last : Element { return value.last! }
    
    var array : [Element] { return value }
    
    var count : Int { return value.count }
    
    var first : Element { return value.first! }
    
    func append(_ elem: Element) {
        value.append(elem)
    }
    
    subscript(index: Int) -> Element {
        get { return value[index] }
    }
    
    subscript(range: CountableRange<Int>) -> ArraySlice<Element> {
        get { return value[range] }
    }
}

public struct BufferedLazyList < Element > {
    
    fileprivate(set) var buffer : Buffer<Element>
    public init(start: Element, rule: @escaping (Element) -> Element) {
        self.buffer = Buffer<Element>(start: start)
        self.rule = rule
    }
    
    fileprivate(set) var rule : (Element) -> Element
}

extension BufferedLazyList : Collection {
    
    public mutating func reduceBufferSize(to: Int) {
        let endIndex = to < 1 ? 1 : to
        guard buffer.count > endIndex else { return }
        self.buffer = Buffer<Element>(value: Array(buffer[0..<endIndex]))!
    }
    
    public mutating func clearBuffer() {
        self.buffer = Buffer<Element>(start: self.buffer.first)
    }
    
    public var bufferCount: Int { return buffer.count }
    
    public func lazymap(_ transform: @escaping (Element) -> Element) -> BufferedLazyList<Element> {
        let rule = self.rule
        return BufferedLazyList<Element>(start: buffer.first) { transform(rule($0)) }
    }
    
    public func get(first: Int) -> [Element] {
        guard first >= 0 else { fatalError() }
        guard first > buffer.count else { return Array(buffer[0..<first]) }
        
        for _ in buffer.count..<first { buffer.append(rule(buffer.last)) }
        return buffer.array
    }
    
    public subscript(index: Int) -> Element {
        get {
            guard index >= buffer.count else { return buffer[index] }
            
            for _ in buffer.count...index { buffer.append(rule(buffer.last)) }
            return buffer.last
        }
    }
    
    public func index(after: Int) -> Int { return after + 1 }
    
    public var startIndex : Int { return 0 }
    
    public var endIndex : Int { return Int.max }
    
    public var count : Int { return Int.max }
    
    public var first : Element { return buffer.first }
}
