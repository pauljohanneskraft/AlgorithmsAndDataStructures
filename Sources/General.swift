//
//  General.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 13.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public func * (lhs: String, rhs: UInt) -> String {
	var result = ""
	for _ in 0..<rhs { result += lhs }
	return result
}

public func * (lhs: String, rhs: Int) -> String { return lhs * UInt(rhs) }
