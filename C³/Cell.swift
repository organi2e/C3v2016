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

import simd

public class Cell: ManagedObject {
	enum Ready {
		case State
		case Train
		case Delta
	}
	let group: DispatchGroup = DispatchGroup()
	var ready: Set<Ready> = []
	var state: RingBuffer<Buffer<Float>> = RingBuffer<Buffer<Float>>(array: [])
	var train: RingBuffer<Buffer<Float>> = RingBuffer<Buffer<Float>>(array: [])
	var error: RingBuffer<Buffer<Float>> = RingBuffer<Buffer<Float>>(array: [])
	var level: RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)> = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: [])
	var nabla: RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)> = RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)>(array: [])
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
		error = RingBuffer<Buffer<Float>>(array: (0..<depth).map {(_)in
			return context.newBuffer(count: count)
		})
		level = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: (0..<depth).map {(_)in
			return (
				χ: context.newBuffer(count: count),
				μ: context.newBuffer(count: count),
				λ: context.newBuffer(count: count)
			)
		})
		nabla = RingBuffer<(φ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)>(array: (0..<depth).map {(_)in
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
	private func enter(commandBuffer: CommandBuffer) {
		group.enter()
	}
	private func leave(commandBuffer: CommandBuffer) {
		group.leave()
	}
	private func merge() {
		group.wait()
	}
	public func collect_clear(ignore: Set<Cell> = []) {
		if ignore.contains(self) {
			
		} else if ready.contains(.State) {
			ready.remove(.State)
			level.progress()
			do {
				let commandBuffer: CommandBuffer = context.newCommandBuffer()
				enter(commandBuffer: commandBuffer)
				input.forEach {
					$0.collect_clear(commandBuffer: commandBuffer, ignore: ignore.union([self]))
				}
				bias.collect_clear(commandBuffer: commandBuffer)
				commandBuffer.addCompletedHandler(leave)
				commandBuffer.commit()
			}
		}
	}
	public func collect() {
		let commandBuffer: CommandBuffer = context.newCommandBuffer()
		commandBuffer.commit()
	}
	internal func collect(commandBuffer: CommandBuffer, ignore: Set<Cell>) -> LaObjet<Float> {
		if ignore.contains(self) {
			return _χ
		} else if ready.contains(.State) {
			do {
				let commandBuffer: CommandBuffer = context.newCommandBuffer()
				let xs: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = input.map {
					$0.collect(commandBuffer: commandBuffer, ignore: ignore.union([self]))
				}
				let ys: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = []
				let ref: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = xs + ys
				let mix: (χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>) = ref.reduce(bias.collect()) {
					( $0.0.χ + $0.1.χ, $0.0.μ + $0.1.μ, $0.0.σ + $0.1.σ )
				}
				commandBuffer.commit()
				commandBuffer.waitUntilCompleted()
				assert(mix.χ.copy(to: level.curr.χ.address))
				assert(mix.μ.copy(to: level.curr.μ.address))
				assert(mix.σ.copy(to: level.curr.λ.address))
			}
			do {
				commandBuffer.enqueue()
				
			}
			do {
				let commandBuffer: CommandBuffer = context.newCommandBuffer()
				enter(commandBuffer: commandBuffer)
				commandBuffer.addCompletedHandler(leave)
				commandBuffer.commit()
			}
			ready.insert(.State)
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
			Δ: Δ,
			gradμ: gradμ,
			gradσ: gradσ
		)
	}
}
extension Cell {
	public var active: [Bool] {
		get {
			return []
		}
	}
	public var answer: Array<Bool> {
		set {
			if 0 < width {
				let commandBuffer: CommandBuffer = context.newCommandBuffer()
				func completed(commandBuffer: CommandBuffer) {
				
				}
				commandBuffer.blit {
					$0.sync(buffer: train.curr)
				}
				commandBuffer.addCompletedHandler(completed)
				commandBuffer.commit()
			}
		}
		get {
			var result: Array<Bool> = Array<Bool>(repeating: false, count: Int(width))
			func completed(commandBuffer: CommandBuffer) {
				for k in 0..<Int(width) {
					result[k] = 0 < train.curr[k]
				}
			}
			let commandBuffer: CommandBuffer = context.newCommandBuffer()
			commandBuffer.blit {
				$0.sync(buffer: train.curr)
			}
			commandBuffer.addCompletedHandler(completed)
			commandBuffer.commit()
			commandBuffer.waitUntilCompleted()
			return result
		}
	}
}
extension Cell {
	internal var χ: LaObjet<Float> {
		return LaObjet<Float>(valuer: state.curr.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var ψ: LaObjet<Float> {
		return LaObjet<Float>(valuer: train.curr.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var Δ: LaObjet<Float> {
		return LaObjet<Float>(valuer: error.curr.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _χ: LaObjet<Float> {
		return LaObjet<Float>(valuer: state.prev.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _ψ: LaObjet<Float> {
		return LaObjet<Float>(valuer: train.prev.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _Δ: LaObjet<Float> {
		return LaObjet<Float>(valuer: error.prev.address, rows: width, cols: 1, deallocator: nil)
	}
}
extension Cell {
	internal var φ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.curr.χ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var μ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.curr.μ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var λ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.curr.λ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _φ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.prev.χ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _μ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.prev.μ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _λ: LaObjet<Float> {
		return LaObjet<Float>(valuer: level.prev.λ.address, rows: width, cols: 1, deallocator: nil)
	}
}
extension Cell {
	internal var gradφ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.curr.φ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var gradμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.curr.φ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var gradσ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.curr.φ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _gradφ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.prev.φ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _gradμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.prev.φ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _gradσ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.prev.φ.address, rows: width, cols: 1, deallocator: nil)
	}
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
