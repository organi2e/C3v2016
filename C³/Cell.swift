//
//  Cell.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import LaObjet
import Distribution
import Maschine
import CoreData

public class Cell: ManagedObject {
	var level: RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)> = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: [])
	var delta: RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)> = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)>(array: [])
	var distribution: SymmetricStableDistribution = DegenerateDistribution()
}
extension Cell {
	override func setup(context: Context) throws {
		let count: Int = 2
		level = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: (0..<count).map {(_)in
			return (
				context.newBuffer(count: Int(width)),
				context.newBuffer(count: Int(width)),
				context.newBuffer(count: Int(width))
			)
		})
		delta = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)>(array: (0..<count).map {(_)in
			return (
				context.newBuffer(count: Int(width)),
				context.newBuffer(count: Int(width)),
				context.newBuffer(count: Int(width))
			)
		})
	}
}
extension Cell {
	public func collect(ignore: Set<Cell> = Set<Cell>()) -> LaObjet<Float> {
		input.map {
			$0.collect(ignore: ignore.union([self]))
		}
		return LaObjet(identité: 1)
	}
	public func correct(ignore: Set<Cell> = Set<Cell>()) -> (Δ: LaObjet<Float>, gradμ: LaObjet<Float>, gradσ: LaObjet<Float>) {
		return (
			Δ: LaObjet(valuer: 0),
			gradμ: LaObjet(valuer: 0),
			gradσ: LaObjet(valuer: 0)
		)
	}
}
extension Cell {
	@NSManaged var width: UInt
	@NSManaged var label: String
	@NSManaged var attribute: Dictionary<String, Any>
	@NSManaged var input: Set<Edge>
	@NSManaged var output: Set<Edge>
	@NSManaged var bias: Bias
}
extension Context {
	public func newCell(width: UInt, label: String = "", recur: Bool = false, input: Array<Cell> = Array<Cell>()) throws -> Cell {
		guard let cell: Cell = new() else {
			throw EntityError.InsertionError(of: Cell.self)
		}
		cell.width = width
		cell.label = label
		cell.attribute = Dictionary<String, Any>()
		cell.input = Set<Edge>()
		cell.output = Set<Edge>()
		try cell.setup(context: self)
		do {
			let _: Bias = try newBias(cell: cell)
		} catch {
			delete(cell)
			throw EntityError.InsertionError(of: Bias.self)
		}
		try input.forEach {
			let _: Edge = try newEdge(output: cell, input: $0)
		}
		return cell
	}
}
