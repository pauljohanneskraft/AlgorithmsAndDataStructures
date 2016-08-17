//
//  List.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 17.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public protocol List {
	associatedtype Element
	
	var array : [Element] { get }
	
	mutating func insert(_: Element, at: Int) throws
	mutating func remove(at: Int) throws -> Element
	
}
