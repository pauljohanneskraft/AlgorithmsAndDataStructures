//
//  Pattern_Matching.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public extension String {
	
	private enum NeedlemanWunschDirection {
		case top, left, diagonal
	}
    
	public static func needlemanWunsch(
        comparing cmp: String,
        to other: String,
        match: Int = 1,
        mismatch: Int = -1,
        insertion: Int = -1,
        deletion: Int = -1) -> [(String, String)] {
		
		let cmpc  = cmp.count + 1
		let count = other.count + 1
		
		var matrix = [[(Int, [NeedlemanWunschDirection])]](
            repeating: [(Int, [NeedlemanWunschDirection])](repeating: (0, []), count: cmpc),
            count: count
        )
		
		for i in 0..<cmpc { matrix[0][i] = (-i, [.left]) } // setup
		for i in 0..<count { matrix[i][0] = (-i, [.top ]) } // setup
		
		for i in 1..<count {		// rows
			let ai = other.index(other.startIndex, offsetBy: i-1)
			for j in 1..<cmpc {		// columns
                let bj = cmp.index( cmp.startIndex, offsetBy: j-1)
                let diagonal: Int = matrix[i-1][j-1].0 + (other[ai] == cmp[bj] ? match: mismatch)
                let left: Int = matrix[i  ][j-1].0 + insertion
                let top: Int  = matrix[i-1][j  ].0 + deletion
                matrix[i][j] = matrixContent(diagonal: diagonal, left: left, top: top)
			}
			
		}
		
		return String.getAllWords(matrix, strings: (other, cmp), coordinates: (count - 1, cmpc - 1), appending: ("", ""))
	}
    
    private static func matrixContent(diagonal: Int, left: Int, top: Int)
        -> (Int, [NeedlemanWunschDirection]) {
            guard diagonal >= top else {
                return (top, [.top])
            }
            
            if diagonal < left {
                return top < left ? (left, [.left]) : (top, [.top, .left])
            } else if left < diagonal {
                return (diagonal, (top >= diagonal ? [.top] : []) + [.diagonal])
            }
            return (diagonal, [.left, .diagonal] + (top == diagonal ? [.top] : []))
    }
    
	private static func getAllWords(
        _ matrix: [[(Int, [NeedlemanWunschDirection])]],
        strings: (String, String),
        coordinates: (Int, Int),
        appending: (String, String)) -> [(String, String)] {
		
		guard coordinates != (0, 0) else {
            return [(String(appending.0.reversed()), String(appending.1.reversed()))]
        }
		
		var result = [(String, String)]()
		
		for dir in matrix[coordinates.0][coordinates.1].1 {
			let newCoordinates: (Int, Int)
			let newAppending: (String, String)
			switch dir {
			case .top:
				newCoordinates = (coordinates.0 - 1, coordinates.1)
				newAppending = (
					appending.0 + "\(strings.0[strings.0.index(strings.0.startIndex, offsetBy: coordinates.0 - 1)])",
					appending.1 + "-"
				)
			case .left:
				newCoordinates = (coordinates.0, coordinates.1 - 1)
				newAppending = (
					appending.0 + "-",
					appending.1 + "\(strings.1[strings.1.index(strings.1.startIndex, offsetBy: coordinates.1 - 1)])"
				)
			case .diagonal:
				newCoordinates = (coordinates.0 - 1, coordinates.1 - 1)
				newAppending = (
					appending.0 + "\(strings.0[strings.0.index(strings.0.startIndex, offsetBy: coordinates.0 - 1)])",
					appending.1 + "\(strings.1[strings.1.index(strings.1.startIndex, offsetBy: coordinates.1 - 1)])"
				)
			}
			result.append(contentsOf:
                getAllWords(matrix, strings: strings, coordinates: newCoordinates, appending: newAppending)
            )
		}
		return result
	}
}
