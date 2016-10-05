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

class Edge: Arcane {
	internal func collect_clear(commandBuffer: CommandBuffer, ignore: Set<Cell>) {
		input.collect_clear(ignore: ignore)
		refresh(commandBuffer: commandBuffer, distribution: output.distribution)
	}
	internal func collect(ignore: Set<Cell>) -> (χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>) {
		let activator: LaObjet = input.collect(ignore: ignore)
		let distribution = output.distribution
		return(
			χ: matrix_product(χ, activator),
			μ: matrix_product(distribution.scale(μ: μ), distribution.scale(μ: activator)),
			σ: matrix_product(distribution.scale(σ: σ), distribution.scale(σ: activator))
		)
	}
	internal func correct_clear(ignore: Set<Cell>) {
		
	}
	internal func correct(ignore: Set<Cell>, activator: LaObjet<Float>) -> LaObjet<Float> {
		//let (Δ: LaObjet<Float>, gradμ: LaObjet<Float>, gradσ: LaObjet<Float>) = output.correct(ignore: ignore)
		return (
			χ: matrix_product(χ, activator)
		)
	}
}
extension Edge {
	@NSManaged var input: Cell
	@NSManaged var output: Cell
}
extension Context {
	internal func newEdge(output: Cell, input: Cell) throws -> Edge {
		guard let edge: Edge = new() else {
			throw EntityError.InsertionError(of: Edge.self)
		}
		edge.output = output
		edge.input = input
		edge.resize(rows: output.width, cols: input.width)
		try edge.setup(context: self)
		return edge
	}
}
