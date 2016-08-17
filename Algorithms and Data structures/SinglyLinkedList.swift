//
//  SinglyLinkedList.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct SinglyLinkedList < Element > : List {
	
	mutating public func pushBack(_ element: Element) {
		if root == nil	{ root = SinglyLinkedItem(data: element) }
		else			{ root!.pushBack(element) }
	}
	
	public mutating func popBack() -> Element? {
		if root?.next == nil { let tmp = root?.data; root = nil; return tmp }
		return root?.popBack()
	}
	
	public subscript(index: Int) -> Element? {
		get {
			guard index >= 0 else { return nil }
			var current = root
			for _ in 0..<index { current = current?.next }
			return current?.data
		}
		set {
			guard newValue != nil else { return }
			guard root != nil else {
				assert(index == 0)
				root = SinglyLinkedItem(data: newValue!)
				return
			}
			
			if index == 0 {
				root = SinglyLinkedItem(data: newValue!, next: root?.next)
				return
			}
			
			var current = root
			var next	= root?.next
			var index = index - 1
			
			while index > 0 {
				current = current?.next
				next	= current?.next
				assert(current != nil)
				index -= 1
			}
			current!.next = SinglyLinkedItem(data: newValue!, next: next?.next)
		}
	}
	
	public mutating func insert(_ data: Element, at index: Int) throws {
		guard root != nil else {
			if index == 0	{ root = SinglyLinkedItem(data: data) }
			else			{ throw ListError.IndexOutOfRange }
			return
		}
		
		var current = root
		var next	= root?.next
		var index = index - 1
		
		while index > 0 {
			current = current?.next
			next	= current?.next
			if current == nil { throw ListError.IndexOutOfRange }
			index -= 1
		}
		
		current!.next = SinglyLinkedItem(data: data, next: next)
	}
	
	public mutating func remove(at index: Int) throws -> Element {
		guard index >= 0 else { throw ListError.IndexOutOfRange }
		
		if index == 0 {
			let tmp = root!.data
			self.root = root?.next
			return tmp
		}
		
		var current = root
		var next	= root?.next
		var index = index - 1
		
		while index > 0 {
			current = current?.next
			next	= current?.next
			if current == nil { throw ListError.IndexOutOfRange }
			index -= 1
		}
		
		let tmp = current!.next!.data
		current!.next = next?.next
		return tmp
	}
	
	private var root : SinglyLinkedItem < Element >?
	
	public init() { root = nil }
	
	public init(arrayLiteral: Element...) {
		self.init()
		self.array = arrayLiteral
	}
	
	public var array: [Element] {
		get {
			guard root != nil else { return [] }
			return root!.array
		}
		set {
			guard newValue.count > 0 else { return }
			self.root = SinglyLinkedItem(data: newValue.first!)
			for e in newValue.dropFirst() {
				self.root!.pushBack(e)
			}

		}
	}
	
	public var description : String {
		if root == nil { return "[]" }
		return root!.description
	}
	
}

private class SinglyLinkedItem<Element> {
    let data : Element
    var next : SinglyLinkedItem?
    
    init(data: Element, next: SinglyLinkedItem? = nil) {
        self.data = data
        self.next = next
    }
	
	var array: [Element] {
		let result = next?.array
		if result != nil { return [data] + result! }
		return [data]
	}
	
	func popBack() -> Element {
		assert(next != nil)
		if next!.next == nil {
			let tmp = next!.data
			next = nil
			return tmp
		} else { return next!.popBack() }
	}
	
	var description : String {
		if next == nil { return "\(data)" }
		return "\(data) -> \(next!.description)"
	}
	
	func pushBack(_ newData: Element) {
		if next == nil	{ next = SinglyLinkedItem(data: newData) }
		else			{ next!.pushBack(newData) }
	}
    
}
