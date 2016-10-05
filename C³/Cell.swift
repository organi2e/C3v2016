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
	enum Ready {
		case State
		case Train
		case Delta
	}
	var ready: Set<Ready> = []
	var state: RingBuffer<Buffer<Float>> = RingBuffer<Buffer<Float>>(array: [])
	var train: RingBuffer<Buffer<Float>> = RingBuffer<Buffer<Float>>(array: [])
	var level: RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)> = RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: [])
	var delta: RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)> = RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)>(array: [])
	var distribution: SymmetricStableDistribution = DegenerateDistribution()
}
extension Cell {
	override func setup(context: Context) throws {
		let depth: Int = 2
		let count: Int = Int(width)
		state = RingBuffer<Buffer<Float>>(array: (0..<depth).map {(_)in
			return context.newBuffer(count: count)
		})
		train = RingBuffer<Buffer<Float>>(array: (0..<depth).map {(_)in
			return context.newBuffer(count: count)
		})
		level = RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: (0..<depth).map {(_)in
			return (
				φ: context.newBuffer(count: count),
				μ: context.newBuffer(count: count),
				λ: context.newBuffer(count: count)
			)
		})
		delta = RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)>(array: (0..<depth).map {(_)in
			return (
				φ: context.newBuffer(count: count),
				μ: context.newBuffer(count: count),
				σ: context.newBuffer(count: count)
			)
		})
		distribution = try context.newDistribution(type: type)
	}
}
extension Cell {
	public func collect_clear(ignore: Set<Cell> = []) {
		if ignore.contains(self) {
		} else if ready.contains(.State) {
			ready.remove(.State)
			level.progress()
			do {
				let commandBuffer: CommandBuffer = context.newCommandBuffer()
				input.forEach {
					$0.collect_clear(commandBuffer: commandBuffer, ignore: ignore.union([self]))
				}
				bias.collect_clear(commandBuffer: commandBuffer)
				commandBuffer.commit()
			}
		}
	}
	public func collect(ignore: Set<Cell> = []) -> LaObjet<Float> {
		if ignore.contains(self) {
			return _χ
		} else if ready.contains(.State) {
			let xs: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = input.map {
				$0.collect(ignore: ignore.union([self]))
			}
			let ys: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = []
			let ref: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = xs + ys
			let mix: (χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>) = ref.reduce(bias.collect()) {
				( $0.0.χ + $0.1.χ, $0.0.μ + $0.1.μ, $0.0.σ + $0.1.σ)
			}
			assert(mix.χ.copy(to: level.curr.φ.address))
			assert(mix.μ.copy(to: level.curr.μ.address))
			assert(mix.σ.copy(to: level.curr.λ.address))
			distribution.synth(λ: level.curr.λ, σ: level.curr.λ)
		}
		return χ
	}
	public func correct_clear(ignore: Set<Cell> = Set<Cell>()) {
		output.forEach {
			$0.correct_clear(ignore: ignore.union(Set<Cell>(arrayLiteral: self)))
		}
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
	internal var χ: LaObjet<Float> {
		return LaObjet<Float>(valuer: state.curr.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var ψ: LaObjet<Float> {
		return LaObjet<Float>(valuer: train.curr.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _χ: LaObjet<Float> {
		return LaObjet<Float>(valuer: state.prev.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _ψ: LaObjet<Float> {
		return LaObjet<Float>(valuer: train.prev.address, rows: width, cols: 1, deallocator: nil)
	}
}
extension Cell {
	internal var φ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.curr.φ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var μ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.curr.μ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var λ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.curr.λ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _φ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.prev.φ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _μ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.prev.μ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _λ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.prev.λ.address, rows: width, cols: 1, deallocator: nil)
	}
}
extension Cell {

}
extension Cell {
	@objc public enum DistributionType: Int {
		case Degenerate
		case Cauchy
		case Gaussian
	}
}
extension Cell {
	@NSManaged var width: UInt
	@NSManaged var label: String
	@NSManaged var type: DistributionType
	@NSManaged var attribute: Dictionary<String, Any>
	@NSManaged var input: Set<Edge>
	@NSManaged var output: Set<Edge>
	@NSManaged var bias: Bias
}
extension Context {
	public func newCell(type: Cell.DistributionType, width: UInt, label: String = "", recur: Bool = false, input: Array<Cell> = Array<Cell>()) throws -> Cell {
		guard let cell: Cell = new() else {
			throw EntityError.InsertionError(of: Cell.self)
		}
		cell.type = type
		cell.width = width
		cell.label = label
		cell.attribute = Dictionary<String, Any>()
		cell.input = Set<Edge>()
		cell.output = Set<Edge>()
		try cell.setup(context: self)
		try input.forEach {
			let _: Edge = try newEdge(output: cell, input: $0)
		}
		let _: Bias = try newBias(cell: cell)
		return cell
	}
	public func searchCell(type: Cell.DistributionType? = nil, width: UInt? = nil, label: String? = nil) throws -> [Cell] {
		var attribute: Dictionary<String, Any> = Dictionary<String, Any>()
		if let type: Cell.DistributionType = type {
			attribute.updateValue(type.rawValue, forKey: "type")
		}
		if let width: UInt = width {
			attribute.updateValue(width, forKey: "width")
		}
		if let label: String = label {
			attribute.updateValue(label, forKey: "label")
		}
		return try fetch(attribute: attribute)
	}
	public func newDistribution(type: Cell.DistributionType) throws -> SymmetricStableDistribution {
		switch type {
		case .Degenerate:
			return DegenerateDistribution()
		case .Cauchy:
			return DegenerateDistribution()
		case .Gaussian:
			return DegenerateDistribution()
		}
	}
}
