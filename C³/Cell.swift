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
	var delta: RingBuffer<Buffer<Float>> = RingBuffer<Buffer<Float>>(array: [])
	var level: RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)> = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: [])
	var nabla: RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)> = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: [])
	var distribution: SymmetricStableDistribution = DegenerateDistribution()
	
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
		delta = RingBuffer<Buffer<Float>>(array: (0..<depth).map {(_)in
			return context.newBuffer(count: count)
		})
		level = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: (0..<depth).map {(_)in
			return (
				χ: context.newBuffer(count: count),
				μ: context.newBuffer(count: count),
				λ: context.newBuffer(count: count)
			)
		})
		nabla = RingBuffer<(χ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)>(array: (0..<depth).map {(_)in
			return (
				χ: context.newBuffer(count: count),
				μ: context.newBuffer(count: count),
				λ: context.newBuffer(count: count)
			)
		})
		distribution = try context.newDistribution(type: type)
	}
}
extension Cell {
	public func collect_clear(ignore: Set<Cell> = Set<Cell>()) {
		if ignore.contains(self) {
			
		} else if ready.contains(.State) {
			ready.remove(.State)
			level.progress()
			state.progress()
			
			do {
				let commandBuffer: CommandBuffer = context.newCommandBuffer()
				
				commandBuffer.blit {
					$0.fill(buffer: level.curr.χ, value: 0)
					$0.fill(buffer: level.curr.μ, value: 0)
					$0.fill(buffer: level.curr.λ, value: 0)
					$0.fill(buffer: state.curr, value: 0)
				}
				input.forEach {
					$0.collect_clear(commandBuffer: commandBuffer, ignore: ignore.union([self]))
				}
				bias.collect_clear(commandBuffer: commandBuffer)
				
				commandBuffer.fork(group: group)
				//commandBuffer.enqueue()
				commandBuffer.commit()
				//commandBuffer.waitUntilCompleted()
			}
		}
	}
	public func collect(ignore: Set<Cell> = Set<Cell>()) -> LaObjet<Float> {
		if ignore.contains(self) {
			return _χ
		} else if !ready.contains(.State) {
			ready.insert(.State)
			do {
				let xs: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = input.map {
					$0.collect(ignore: ignore.union([self]))
				}
				let ys: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = []
				let ref: [(χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>)] = xs + ys
				let mix: (χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>) = ref.reduce(bias.collect()) {
					( $0.0.χ + $0.1.χ, $0.0.μ + $0.1.μ, $0.0.σ + $0.1.σ )
				}
				group.wait()
				assert(mix.χ.copy(to: level.curr.χ.address))
				assert(mix.μ.copy(to: level.curr.μ.address))
				assert(mix.σ.copy(to: level.curr.λ.address))
			}
			do {
				let src: UnsafePointer<float4> = UnsafePointer<float4>(OpaquePointer(level.curr.χ.pointer))
				let dst: UnsafeMutablePointer<float4> = UnsafeMutablePointer<float4>(OpaquePointer(state.curr.pointer))
				for k in 0..<Int((width-1)/4+1) {
					dst[k] = step(src[k], edge: float4(0))
				}
			}
			do {
				let commandBuffer: CommandBuffer = context.newCommandBuffer()
				
				distribution.eval(commandBuffer: commandBuffer, gradμ: nabla.curr.μ, gradλ: nabla.curr.λ, μ: level.curr.μ, λ: level.curr.λ)
				
				commandBuffer.fork(group: group)
				//commandBuffer.enqueue()
				commandBuffer.commit()
				//commandBuffer.waitUntilCompleted()
			}
		}
		return χ
	}
	public func correct_clear(ignore: Set<Cell> = Set<Cell>()) {
		if ignore.contains(self) {
			
		} else if ready.contains(.Delta) {
			ready.remove(.Delta)
			train.progress()
			nabla.progress()
			error.progress()
			delta.progress()
			do {
				output.forEach {
					$0.correct_clear(ignore: ignore.union([self]))
				}
				bias.correct_clear()
			}
		}
	}
	public func correct(ignore: Set<Cell> = Set<Cell>()) -> (Δ: LaObjet<Float>, gradμ: LaObjet<Float>, gradλ: LaObjet<Float>) {
		if ignore.contains(self) || !ready.contains(.State) {
			return (
				Δ: (2 / Float(input .map { $0.cols } .reduce(1) { $0.0 + $0.1 })) * _Δ,
				gradμ: _gradμ,
				gradλ: _gradλ
			)
		} else if !ready.contains(.Delta) {
			ready.insert(.Delta)
			do {
				
				let commandBuffer: CommandBuffer = context.newCommandBuffer()
				
				let ε: LaObjet<Float> = ready.contains(.Train) ? χ - ψ : output.map {
					$0.correct(commandBuffer: commandBuffer, ignore: ignore.union([self]))
				}.reduce(LaObjet<Float>(valuer: 0)) {
					$0.0 + $0.1
				}
				
				group.wait()
				assert(ε.copy(to: error.curr.address))

				let src: UnsafePointer<float4> = UnsafePointer<float4>(OpaquePointer(error.curr.pointer))
				let dst: UnsafeMutablePointer<float4> = UnsafeMutablePointer<float4>(OpaquePointer(delta.curr.pointer))
				
				for k in 0..<Int((width-1)/4+1) {
					dst[k] = sign(src[k])
				}
				
				bias.correct(commandBuffer: commandBuffer, Δ: Δ, gradμ: gradμ, gradλ: gradλ)
				
				commandBuffer.fork(group: group)
				//commandBuffer.enqueue()
				commandBuffer.commit()
				//commandBuffer.waitUntilCompleted()
			}
		}
		return (
			Δ: (2 / Float(input .map { $0.cols } .reduce(1) { $0.0 + $0.1 })) * Δ,
			gradμ: gradμ,
			gradλ: gradλ
		)
	}
}
extension Cell {
	public var active: Array<Bool> {
		set {
			let count: Int = min(newValue.count, Int(width))
			let commandBuffer: CommandBuffer = context.newCommandBuffer()
			func completed(commandBuffer: CommandBuffer) {
				(0..<count).forEach {
					state.curr[$0] = newValue[$0] ? 1 : 0
				}
				state.curr.didChange()
			}
			commandBuffer.blit {
				$0.sync(buffer: state.curr)
			}
			commandBuffer.addCompletedHandler(completed)
			commandBuffer.commit()
			ready.insert(.State)
		}
		get {
			let count: Int = Int(width)
			let commandBuffer: CommandBuffer = context.newCommandBuffer()
			var result: Array<Bool> = Array<Bool>(repeating: false, count: count)
			func completed(commandBuffer: CommandBuffer) {
				(0..<count).forEach {
					result[$0] = 0 < state.curr[$0]
				}
			}
			commandBuffer.blit {
				$0.sync(buffer: state.curr)
			}
			commandBuffer.addCompletedHandler(completed)
			commandBuffer.commit()
			commandBuffer.waitUntilCompleted()
			return result
		}
	}
	public var answer: Array<Bool> {
		set {
			let count: Int = min(newValue.count, Int(width))
			let commandBuffer: CommandBuffer = context.newCommandBuffer()
			func completed(commandBuffer: CommandBuffer) {
				(0..<count).forEach {
					train.curr[$0] = newValue[$0] ? 1 : 0
				}
			}
			commandBuffer.blit {
				$0.sync(buffer: train.curr)
			}
			commandBuffer.addCompletedHandler(completed)
			commandBuffer.commit()
			commandBuffer.waitUntilCompleted()
			ready.insert(.Train)
		}
		get {
			let count: Int = Int(width)
			var result: Array<Bool> = Array<Bool>(repeating: false, count: count)
			func completed(commandBuffer: CommandBuffer) {
				(0..<count).forEach {
					result[$0] = 0 < train.curr[$0]
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
	internal var gradχ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.curr.χ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var gradμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.curr.μ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var gradλ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.curr.λ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _gradχ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.prev.χ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _gradμ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.prev.μ.address, rows: width, cols: 1, deallocator: nil)
	}
	internal var _gradλ: LaObjet<Float> {
		return LaObjet<Float>(valuer: nabla.prev.λ.address, rows: width, cols: 1, deallocator: nil)
	}
}
extension Cell {
	@objc public enum DistributionType: UInt16 {
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
			return try GaussianDistribution(maschine: maschine)
		case .Gaussian:
			return try GaussianDistribution(maschine: maschine)
		}
	}
}
