//
//  Decay.swift
//  C³
//
//  Created by Kota on 10/3/16.
//
//

import Maschine
import LaObjet
import Distribution
import Optimizer

internal class Decay: ManagedObject {

	private static let keys: (refresh: String, λ: String) = (refresh: "decayRefresh", λ: "lambda")
	
	var last: LaObjet<Float> = LaObjet<Float>(valuer: 0)
	var optimizer: Optimizer?
	
	var pages: RingBuffer<(dμdr: Array<Float>, dλdr: Array<Float>)> = RingBuffer(array: Array())
	var metal: (
		r: Buffer<Float>,
		λr: Buffer<Float>,
		Δr: Buffer<Float>,
		refresh: ComputePipelineState
	)!
	let lock: DispatchGroup = DispatchGroup()
	
	override func setup(context: Context) throws {
		try super.setup(context: context)
		do {
			let depth: Int = 2
			let count: Int = Int(width)
			pages = RingBuffer<(dμdr: Array<Float>, dλdr: Array<Float>)>(array: (0..<depth).map {(_)in(
				dμdr: Array<Float>(repeating: 0, count: count),
				dλdr: Array<Float>(repeating: 0, count: count)
			)})
			metal = (
				r: context.newBuffer(count: count),
				λr: context.newBuffer(data: lambda),
				Δr: context.newBuffer(count: count),
				refresh: try context.newComputePipelineState(name: Decay.keys.refresh)
			)
			optimizer = try context.newOptimizer(count: count)
			setPrimitiveValue(Data(bytesNoCopy: metal.λr.pointer, count: count, deallocator: .none), forKey: Decay.keys.λ)
		}
	}
}
extension Decay {
	@NSManaged var cell: Cell
	@NSManaged var width: UInt
	@NSManaged var lambda: Data
}
extension Decay {
	
	private static let key: String = "lambda"
	
	func refresh(commandBuffer: CommandBuffer) {
		
		func scheduled(commandBuffer: CommandBuffer) {
			willAccessValue(forKey: Decay.key)
			lock.enter()
		}
		
		func completed(commandBuffer: CommandBuffer) {
			lock.leave()
			didAccessValue(forKey: Decay.key)
		}
		
		commandBuffer.addScheduledHandler(scheduled)
		commandBuffer.addCompletedHandler(completed)
		
		lock.wait()
		
		commandBuffer.compute {
			$0.set(pipeline: metal.refresh)
			$0.set(buffer: metal.r, offset: 0, at: 0)
			$0.set(buffer: metal.Δr, offset: 0, at: 0)
			$0.set(buffer: metal.λr, offset: 0, at: 0)
			$0.dispatch(groups: (cell.width-1)/4+1, threads: 1)
		}
	}
	func update(commandBuffer: CommandBuffer, Δr: LaObjet<Float>) {
		
		func scheduled(commandBuffer: CommandBuffer) {
			willChangeValue(forKey: Decay.key)
			lock.enter()
		}
		
		func completed(commandBuffer: CommandBuffer) {
			lock.leave()
			didChangeValue(forKey: Decay.key)
		}
		
		commandBuffer.addScheduledHandler(scheduled)
		commandBuffer.addCompletedHandler(completed)
		
		lock.wait()
		
		assert((Δr*dr).copy(to: metal.Δr.address))
		
		optimizer?.update(commandBuffer: commandBuffer, value: metal.λr, delta: metal.Δr)
		
	}
	internal var dr: LaObjet<Float> {
		return LaObjet<Float>(valuer: metal.Δr.address, rows: width, cols: 1, deallocator: nil)
	}
}
extension Decay {
	func collect_clear(commandBuffer: CommandBuffer) {
		
	}
	func collect() -> (χ: LaObjet<Float>, μ: LaObjet<Float>, σ: LaObjet<Float>) {
		let distribution: SymmetricStableDistribution = cell.distribution
		last = cell._φ
		return (
			χ: r * last,
			μ: distribution.scale(μ: r * cell._μ),
			σ: distribution.scale(σ: r * cell._λ)
		)
	}
	func correct_clear() {
		
	}
	func correct(commandBuffer: CommandBuffer, Δχ: LaObjet<Float>, dχdμ: LaObjet<Float>, dχdλ: LaObjet<Float>) {
		do {
			
		}
	}
	func chain(χ: LaObjet<Float>) -> LaObjet<Float> {
		return matrix_product(LaObjet<Float>(diagonale: r, shift: 0), χ)
	}
	var r: LaObjet<Float> {
		return LaObjet<Float>(valuer: metal.r.address, rows: metal.r.count, cols: 1, deallocator: nil)
	}
	private var δμ: LaObjet<Float> {
		return LaObjet<Float>(diagonale: last, shift: 0)
	}
	private var δλ: LaObjet<Float> {
		return LaObjet<Float>(valuer: 0)
	}
	private var dμdr: LaObjet<Float> {
		return LaObjet<Float>(valuer: pages.curr.dμdr, rows: pages.curr.dμdr.count, cols: 1, deallocator: nil)
	}
	private var dλdr: LaObjet<Float> {
		return LaObjet<Float>(valuer: pages.curr.dλdr, rows: pages.curr.dλdr.count, cols: 1, deallocator: nil)
	}
	private var _dμdr: LaObjet<Float> {
		return LaObjet<Float>(valuer: pages.prev.dμdr, rows: pages.prev.dμdr.count, cols: 1, deallocator: nil)
	}
	private var _dλdr: LaObjet<Float> {
		return LaObjet<Float>(valuer: pages.prev.dλdr, rows: pages.prev.dλdr.count, cols: 1, deallocator: nil)
	}
}
extension Decay {
	func resize(width: UInt) throws {
		self.width = width
		self.lambda = Data(count: MemoryLayout<Float>.size*Int(width))
		try setup(context: context)
	}
}
extension Context {
	func newDecay(cell: Cell) throws -> Decay {
		guard let decay: Decay = new() else { throw EntityError.InsertionError(of: Decay.self) }
		decay.cell = cell
		cell.decay = decay
		try decay.resize(width: cell.width)
		return decay
	}
}
