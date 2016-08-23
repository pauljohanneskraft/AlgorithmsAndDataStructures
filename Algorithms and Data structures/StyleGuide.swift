//
//  StyleGuide.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 23.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

private struct StyleGuide { // always try to use structs, instead of classes
	
	/*
	order:
		1. kind
			- stored properties
			- initializers
			- computed properties
			- subscripts
			- functions
		2. visibility
			- public > internal > private
		3. semantically common
		4. alphabetically
	*/
	
	let a = 10 // always prefer let over var, if possible
	
}
