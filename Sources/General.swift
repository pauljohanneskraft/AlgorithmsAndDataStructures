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
	let result	= lhs * (rhs >> 1)
	guard rhs & 0x1 == 0 else { return result + result + lhs }
	return result + result
}

public func * (lhs: String, rhs: Int) -> String { return lhs * UInt(rhs) }
