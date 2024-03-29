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
	//Put on main memory because they tend to be too large for gpu-memory
	var nablaμ: Array<Float> = Array<Float>()
	var nablaσ: Array<Float> = Array<Float>()
	override func setup(context: Context) throws {
		try super.setup(context: context)
		let count: Int = Int(cell.width * cell.width)
		let commandBuffer: CommandBuffer = context.newCommandBuffer()
		refresh(commandBuffer: commandBuffer, distribution: cell.distribution)
		commandBuffer.commit()
	//	nablaμ = Array<Float>(repeating: 0, count: count*count)
	//	nablaσ = Array<Float>(repeating: 0, count: count*count)
	}
}
extension Bias {
	@NSManaged var cell: Cell
}
extension Bias {
	
}
extension Bias {
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
	internal func correct_clear() {
		
	}
	internal func correct(commandBuffer: CommandBuffer, Δ: LaObjet<Float>, gradμ: LaObjet<Float>, gradλ: LaObjet<Float>) {
		let distribution: SymmetricStableDistribution = cell.distribution
		let λ: LaObjet<Float> = cell.λ
		/*
		do {
			//Feedback
		}
		*/
		do {
			//Always gain
			let dλdc: LaObjet<Float> = -distribution.gradσδ(λ: λ, c: σ)
			let Δσ: LaObjet<Float> = matrix_product((Δ*gradλ).T, dλdc)
			let Δμ: LaObjet<Float> = Δ * gradμ
			update(commandBuffer: commandBuffer, Δμ: Δμ, Δσ: Δσ)
		}
		//update(commandBuffer: commandBuffer, Δμ: Δ*gradμ, Δσ: -Δ*gradλ*λ*λ*σ)
	}
	private var dμdμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nablaμ, rows: rows, cols: rows, deallocator: nil)
	}
	private var dλdσ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nablaμ, rows: rows, cols: rows, deallocator: nil)
	}
}
extension Context {
	internal func newBias(cell: Cell) throws -> Bias {
		guard let bias: Bias = new() else {
			throw EntityError.InsertionError(of: Bias.self)
		}
		bias.cell = cell
		try bias.resize(rows: cell.width, cols: 1)
		return bias
	}
}
