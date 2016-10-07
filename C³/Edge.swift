//
//  Edge.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import LaObjet
import Maschine
import CoreData
import Distribution

class Edge: Arcane {
	var last: LaObjet<Float> = LaObjet<Float>(valuer: 0)
	var dμdμ: Array<Float> = Array<Float>()
	var dλdσ: Array<Float> = Array<Float>()
	var dμdx: Array<Float> = Array<Float>()
	var dλdx: Array<Float> = Array<Float>()
	override func setup(context: Context) throws {
		try super.setup(context: context)
		let commandBuffer: CommandBuffer = context.newCommandBuffer()
		refresh(commandBuffer: commandBuffer, distribution: output.distribution)
		commandBuffer.commit()
		dμdμ = Array<Float>(repeating: 0, count: Int(rows*rows*cols))
		dλdσ = Array<Float>(repeating: 0, count: Int(rows*rows*cols))
		dμdx = Array<Float>(repeating: 0, count: Int(rows*cols))
		dλdx = Array<Float>(repeating: 0, count: Int(rows*cols))
	}
}
extension Edge {
	@NSManaged var input: Cell
	@NSManaged var output: Cell
}
extension Edge {
}
extension Edge {
	internal func collect_clear(commandBuffer: CommandBuffer, ignore: Set<Cell>) {
		input.collect_clear(ignore: ignore)
		refresh(commandBuffer: commandBuffer, distribution: output.distribution)
	}
	internal func collect(ignore: Set<Cell>) -> (χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>) {
		let distribution = output.distribution
		last = input.collect(ignore: ignore)
		return(
			χ: matrix_product(χ, last),
			μ: matrix_product(distribution.scale(μ: μ), distribution.scale(μ: last)),
			σ: matrix_product(distribution.scale(σ: σ), distribution.scale(σ: last))
		)
	}
	internal func correct_clear(ignore: Set<Cell>) {
		output.correct_clear(ignore: ignore)
	}
	internal func correct(commandBuffer: CommandBuffer, ignore: Set<Cell>) -> LaObjet<Float> {
		let distribution: SymmetricStableDistribution = output.distribution
		
		let λ: LaObjet<Float> = output.λ
		
		let (Δ, gradμ, gradλ): (Δ: LaObjet<Float>, gradμ: LaObjet<Float>, gradλ: LaObjet<Float>) = output.correct(ignore: ignore)
		
		let Δμ: LaObjet<Float> = outer_product(Δ*gradμ, last)
		let Δσ: LaObjet<Float> = σ * outer_product(-Δ*gradλ*λ*λ*λ, last * last)
		
		update(commandBuffer: commandBuffer, Δμ: Δμ, Δσ: Δσ)
		
		return matrix_product(χ.T, Δ)
	}
}
extension Context {
	internal func newEdge(output: Cell, input: Cell) throws -> Edge {
		guard let edge: Edge = new() else {
			throw EntityError.InsertionError(of: Edge.self)
		}
		edge.output = output
		edge.input = input
		try edge.resize(rows: output.width, cols: input.width)
		return edge
	}
}
