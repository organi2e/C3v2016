//
//  Bias.swift
//  C³
//
//  Created by Kota on 10/3/16.
//
//

import Foundation

internal class Bias: Arcane {
	
}
extension Bias {
	@NSManaged var cell: Cell
}
extension Bias {
	
}
extension Context {
	func newBias(cell: Cell) throws -> Bias {
		guard let bias: Bias = new() else {
			throw EntityError.InsertionError(of: Bias.self)
		}
		bias.resize(rows: cell.width, cols: 1)
		bias.cell = cell
		try bias.setup(context: self)
		return bias
	}
}
