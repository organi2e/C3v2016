//
//  Bias.swift
//  C³
//
//  Created by Kota on 10/3/16.
//
//

import LaObjet
import Maschine
import Distribution
import Optimizer

internal class Bias: Arcane {
	
}
extension Bias {
	@NSManaged var cell: Cell
}
extension Bias {
	internal func collect_clear(commandBuffer: CommandBuffer) {
		refresh(commandBuffer: commandBuffer, distribution: cell.distribution)
	}
	internal func collect() -> (χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>) {
		let distribution: SymmetricStableDistribution = cell.distribution
		return (
			χ: χ,
			μ: distribution.scale(μ: μ),
			σ: distribution.scale(σ: σ)
		)
	}
}
extension Context {
	internal func newBias(cell: Cell) throws -> Bias {
		guard let bias: Bias = new() else {
			throw EntityError.InsertionError(of: Bias.self)
		}
		bias.resize(rows: cell.width, cols: 1)
		bias.cell = cell
		try bias.setup(context: self)
		return bias
	}
}
