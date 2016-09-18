//
//  General.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 13.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public func * (lhs: String, rhs: UInt) -> String {
	guard rhs > 1 else { guard rhs > 0 else { return "" }; return lhs }
	let res = lhs * (rhs >> 1)
	return res + res + (rhs % 2 == 0 ? "" : lhs)
}

public func * (lhs: String, rhs: Int) -> String { return lhs * UInt(rhs) }
