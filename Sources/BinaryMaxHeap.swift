//
//  BinaryMaxHeap.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct BinaryMaxHeap < Element > : PriorityQueue {
	
	public	let order	: (Element, Element) -> Bool
	private var _array	: [Element]
	
	public	var array	: [Element] {
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
		_array = [elem] + _array
		siftDown(at: 0)
	}
	
	public mutating func pop() -> Element? {
		guard _array.count > 1 else { return _array.popLast() }
		
		swap(&_array[_array.count - 1], &_array[0])
		
		let data = _array.popLast()!
		siftDown(at: 0)
		return data
	}
	
	public mutating func siftDown(at: Int) {
		var i = at
		while true {
			// Index of left child
			var child = (i << 1) | 1
			
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
			if order(_array[i], _array[child]) {
				swap(&_array[i], &_array[child])
				i = child // sifting down child then
			} else { return }
		}
	}
	
}

public extension BinaryMaxHeap where Element : Comparable {
	public init() { self.init { $0 < $1 } }
}

