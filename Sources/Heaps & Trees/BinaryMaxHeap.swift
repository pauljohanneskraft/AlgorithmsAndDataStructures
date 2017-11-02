//
//  BinaryMaxHeap.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct BinaryMaxHeap < Element >: PriorityQueue {
	
	public	let order: (Element, Element) -> Bool
	private var _array: [Element]
	
	public	var array: [Element] {
		get { return _array }
		set {
			_array = newValue
			for i in (0..<(array.count >> 1)).reversed() { siftDown(at: i) }
		}
	}
	
	public init(order: @escaping (Element, Element) -> Bool) {
		self.init(array: [], order: order)
	}
	
	public init(array: [Element], order: @escaping (Element, Element) -> Bool) {
		self.order = order
		self._array = []
		self.array = array
	}
	
	public mutating func push(_ elem: Element) {
		_array.append(elem)
		siftUp(at: _array.indices.last!)
        assertEqual(_array.first.debugDescription, _array.max(by: order).debugDescription)
	}
    
    public var isEmpty: Bool { return _array.isEmpty }
	
	public mutating func pop() -> Element? {
		guard _array.count > 1 else { return _array.popLast() }
		
		let data = _array.popLast()!
		let ret = _array[0]
		_array[0] = data
		siftDown(at: 0)
        assertEqual(_array.first.debugDescription, _array.max(by: order).debugDescription)
		return ret
	}
	
	public mutating func siftDown(at index: Int) {
		
		// Index of left child
		var child = (index << 1) | 1
		
		// is left child in range? / is there a left child?
		guard _array.indices.contains(child) else { return }
		
		// right child exists
		if _array.indices.contains(child + 1) {
			// left child < right child
			if order(_array[child], _array[child + 1]) {
				child += 1 // right child
			}
		}
		// self[i] < self[child]
		if order(_array[index], _array[child]) {
            _array.swapAt(index, child)
			siftDown(at: child) // sifting down child then
		}
	}
	
	public mutating func siftUp(at index: Int) {

		guard _array.indices.contains(index) else { return }
		
		let parent = (index-1) >> 1
		
		guard _array.indices.contains(parent) else { return }
		
		if order(_array[parent], _array[index]) {
            _array.swapAt(parent, index)
			siftUp(at: parent) // sifting down child then
		}
	}
    
    public var description: String {
        return "\(self._array)"
    }
}

public extension BinaryMaxHeap where Element: Comparable {
	public init() { self.init { $0 < $1 } }
}

extension BinaryMaxHeap: CustomStringConvertible {}
