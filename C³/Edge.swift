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
	var cache: RingBuffer<(dμdμ: Array<Float>, dλdσ: Array<Float>, δμ: Array<Float>, δσ: Array<Float>)> = RingBuffer(array: Array())
	
	override func setup(context: Context) throws {
		
		try super.setup(context: context)
		
		do {
			let depth: Int = 2
			let count: Int = Int(rows*rows*cols)
			cache = RingBuffer(array: (0..<depth).map{(_)in(
				dμdμ: Array<Float>(repeating: 0, count: count),
				dλdσ: Array<Float>(repeating: 0, count: count),
				δμ: Array<Float>(repeating: 0, count: count),
				δσ: Array<Float>(repeating: 0, count: count)
			)})
		}
		
		let commandBuffer: CommandBuffer = context.newCommandBuffer()
		refresh(commandBuffer: commandBuffer, distribution: output.distribution)
		commandBuffer.commit()
		
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
		cache.progress()
	}
	internal func correct(commandBuffer: CommandBuffer, ignore: Set<Cell>) -> LaObjet<Float> {
		let distribution: SymmetricStableDistribution = output.distribution
		let (Δ, gradμ, gradλ): (Δ: LaObjet<Float>, gradμ: LaObjet<Float>, gradλ: LaObjet<Float>) = output.correct(ignore: ignore)
		do {
			let stride: UInt = (rows+1)*cols
			assert(outer_product(LaObjet<Float>(valuer: 1, rows: rows, cols: 1), last).copy(to: cache.curr.δμ, cols: stride))
			assert(distribution.gradσδ(λ: output.λ, a: σ, x: last).copy(to: cache.curr.δσ, cols: stride))
		}
		do {
			let dμdμ_: LaObjet<Float> = LaObjet<Float>(valuer: 0) + δμ
			assert(dμdμ_.copy(to: cache.curr.dμdμ))
			
			let dλdσ_: LaObjet<Float> = LaObjet<Float>(valuer: 0) - δσ
			assert(dλdσ_.copy(to: cache.curr.dλdσ))
		}
		do {
			let Δμ: LaObjet<Float> = matrix_product((Δ*gradμ).T, dμdμ)
			let Δσ: LaObjet<Float> = matrix_product((Δ*gradλ).T, dλdσ)
			
			update(commandBuffer: commandBuffer, Δμ: Δμ, Δσ: Δσ)
		}
		return matrix_product(χ.T, Δ)
	}
	private var δμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: cache.curr.δμ, rows: rows, cols: rows*cols, deallocator: nil)
	}
	private var δσ: LaObjet<Float> {
		return LaObjet<Float>(valuer: cache.curr.δσ, rows: rows, cols: rows*cols, deallocator: nil)
	}
	private var _δμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: cache.prev.δμ, rows: rows, cols: rows*cols, deallocator: nil)
	}
	private var _δσ: LaObjet<Float> {
		return LaObjet<Float>(valuer: cache.prev.δσ, rows: rows, cols: rows*cols, deallocator: nil)
	}
	private var dμdμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: cache.curr.dμdμ, rows: rows, cols: rows*cols, deallocator: nil)
	}
	private var dλdσ: LaObjet<Float> {
		return LaObjet<Float>(valuer: cache.curr.dλdσ, rows: rows, cols: rows*cols, deallocator: nil)
	}
	private var _dμdμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: cache.prev.dμdμ, rows: rows, cols: rows*cols, deallocator: nil)
	}
	private var _dλdσ: LaObjet<Float> {
		return LaObjet<Float>(valuer: cache.prev.dλdσ, rows: rows, cols: rows*cols, deallocator: nil)
	}
}
extension Context {
	internal func newEdge(output: Cell, input: Cell) throws -> Edge {
		guard let edge: Edge = new() else { throw EntityError.InsertionError(of: Edge.self) }
		edge.output = output
		edge.input = input
		try edge.resize(rows: output.width, cols: input.width)
		return edge
	}
}
