//
//  BinaryMaxHeap.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct BinaryMaxHeap<Element>: PriorityQueue {
	
	public	let order: (Element, Element) -> Bool
	private var internalArray: [Element]
	
	public	var array: [Element] {
		get { return internalArray }
		set {
			internalArray = newValue
			for i in (0..<(array.count >> 1)).reversed() { siftDown(at: i) }
		}
	}
	
	public init(order: @escaping (Element, Element) -> Bool) {
		self.init(array: [], order: order)
	}
	
	public init(array: [Element], order: @escaping (Element, Element) -> Bool) {
		self.order = order
		self.internalArray = []
		self.array = array
	}
	
	public mutating func push(_ elem: Element) {
		internalArray.append(elem)
		siftUp(at: internalArray.count - 1)
        assertEqual(internalArray.first.debugDescription, internalArray.max(by: order).debugDescription)
	}
    
    public var isEmpty: Bool { return internalArray.isEmpty }
	
	public mutating func pop() -> Element? {
		guard internalArray.count > 1 else { return internalArray.popLast() }
		
		let data = internalArray.removeLast()
		let ret = internalArray[0]
		internalArray[0] = data
		siftDown(at: 0)
        assertEqual(internalArray.first.debugDescription, internalArray.max(by: order).debugDescription)
		return ret
	}
	
	public mutating func siftDown(at index: Int) {
		
		// Index of left child
		var child = (index << 1) | 1
		
		// is left child in range? / is there a left child?
		guard internalArray.indices.contains(child) else { return }
		
		// right child exists
		if internalArray.indices.contains(child + 1) {
			// left child < right child
			if order(internalArray[child], internalArray[child + 1]) {
				child += 1 // right child
			}
		}

        if order(internalArray[index], internalArray[child]) {
            internalArray.swapAt(index, child)
			siftDown(at: child) // sifting down child then
		}
	}
	
	public mutating func siftUp(at index: Int) {

		guard internalArray.indices.contains(index) else { return }
		
		let parent = (index-1) >> 1
		
		guard internalArray.indices.contains(parent) else { return }
		
		if order(internalArray[parent], internalArray[index]) {
            internalArray.swapAt(parent, index)
			siftUp(at: parent) // sifting down child then
		}
	}
    
    public var description: String {
        return internalArray.description
    }
}

public extension BinaryMaxHeap where Element: Comparable {
	public init() { self.init { $0 < $1 } }
}

extension BinaryMaxHeap: CustomStringConvertible {}
