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
		let (Δ, gradμ, gradλ): (Δ: LaObjet<Float>, gradμ: LaObjet<Float>, gradλ: LaObjet<Float>) = output.correct(ignore: ignore)
		/*
		let μactivator: LaObjet<Float> = input.χ
		let σactivator: LaObjet<Float> = distribution.gradσδ(λ: output.λ, a: σ, x: input.χ)
		(0..<rows).forEach {
			do {
				let slice: LaObjet<Float> = μactivator
				assert(slice.copy(to: UnsafePointer<Float>(dμdμ).advanced(by: Int($0*(rows+1)*cols))))
			}
			do {
				let slice: LaObjet<Float> = σactivator[Int($0)..<Int($0+1), 0..<Int(cols)]
				assert(slice.copy(to: UnsafePointer<Float>(dλdσ).advanced(by: Int($0*(rows+1)*cols))))
			}
		}
		let Δμ: LaObjet<Float> = matrix_product((Δ*gradμ).T, LaObjet<Float>(valuer: dμdμ, rows: rows, cols: rows*cols, deallocator: nil))
		let Δσ: LaObjet<Float> = matrix_product((Δ*gradλ).T, LaObjet<Float>(valuer: dλdσ, rows: rows, cols: rows*cols, deallocator: nil))
		*/
		
		let Δμ: LaObjet<Float> = outer_product(Δ*gradμ, last)
		let Δσ: LaObjet<Float> = outer_product(-Δ*gradλ*input.λ*input.λ, last)
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
