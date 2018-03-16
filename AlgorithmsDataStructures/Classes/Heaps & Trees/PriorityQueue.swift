//
//  PriorityQueue.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 23.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

public protocol PriorityQueue {
	associatedtype Element
	init(order: @escaping (Element, Element) -> Bool)
	var order: (Element, Element) -> Bool { get }
	mutating func push(_: Element) throws
	mutating func pop() -> Element?
}
