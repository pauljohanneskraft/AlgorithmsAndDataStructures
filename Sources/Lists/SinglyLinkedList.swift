//
//  SinglyLinkedList.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct SinglyLinkedList<Element> {
    internal var root: Item?
    public init() { root = nil }
}

extension SinglyLinkedList {
    final class Item {
        public let data: Element
        public var next: Item?
        
        public init(data: Element, next: Item?) {
            self.data = data
            self.next = next
        }
        
        public convenience init(data: Element) {
            self.init(data: data, next: nil)
        }
    }
}

extension SinglyLinkedList.Item: ListItem {
    var description: String {
        guard let next = next else {
            return "\(data)"
        }
        return "\(data) -> \(next.description)"
    }
    
    func pushBack(_ newData: Element) {
        guard let next = next else {
            self.next = SinglyLinkedList.Item(data: newData)
            return
        }
        next.pushBack(newData)
    }
}

extension SinglyLinkedList: InternalList {
    typealias Node = Item
    
	mutating public func pushBack(_ element: Element) {
        guard let root = self.root else {
            self.root = Item(data: element)
            return
        }
		root.pushBack(element)
	}
	
	public mutating func popBack() -> Element? {
		guard root?.next != nil else { let tmp = root?.data; root = nil; return tmp }
		return root!.popBack()
	}
	
	public subscript(index: Int) -> Element? {
		get {
			guard index >= 0 else { return nil }
			var current = root
			for _ in 0..<index { current = current?.next }
			return current?.data
		}
		set {
			guard let newValue = newValue else { return }
			guard root != nil else {
				precondition(index == 0, "Index out of bounds. \(index) > 0.")
				root = Item(data: newValue)
				return
			}
			
			if index == 0 {
				root = Item(data: newValue, next: root?.next)
				return
			}
			
			var current = root
			var index = index - 1
			
			while index > 0 {
				current = current?.next
				precondition(current != nil, "Index out of bounds.")
				index -= 1
			}
			
			current!.next = Item(data: newValue, next: current?.next?.next)
		}
	}
	
	public mutating func insert(_ data: Element, at index: Int) throws {
		guard root != nil else {
            guard index == 0 else {
                throw ListError.indexOutOfRange
            }
            root = Item(data: data)
			return
		}
		
		var current = root
		var index = index - 1
		
		while index > 0 {
			current = current?.next
			index -= 1
		}
        
        guard current != nil else { throw ListError.indexOutOfRange }
		
		current!.next = Item(data: data, next: current?.next)
	}
	
	public mutating func remove(at index: Int) throws -> Element {
		guard index >= 0 else { throw ListError.indexOutOfRange }
		
		if index == 0 {
			let tmp = root!.data
			self.root = root?.next
			return tmp
		}
		
		var current = root
		var index = index - 1
		
		while index > 0 {
			current = current?.next
			index -= 1
		}
        
        guard current != nil else { throw ListError.indexOutOfRange }
		
		let next = current?.next
		let tmp = next!.data
		current!.next = next?.next
		return tmp
	}
	
	public var count: Int {
		if root == nil { return 0 }
		return root!.count
	}
	
	public init(arrayLiteral: Element...) {
		self.init()
		self.array = arrayLiteral
	}
	
	public var array: [Element] {
		get {
			return root?.array ?? []
		}
		set {
			guard newValue.count > 0 else { return }
			self.root = Item(data: newValue.first!)
			for e in newValue.dropFirst() {
				self.root!.pushBack(e)
			}

		}
	}
	
	public var description: String {
		if root == nil { return "[]" }
		return "[" + root!.description + "]"
	}
	
}
