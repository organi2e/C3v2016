//
//  Arcane.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//

import CoreData
import LaObjet
import Maschine
import Optimizer
import Distribution

internal class Arcane: ManagedObject {
	
	private static let argmukey: String = "argmu"
	private static let argsigmakey: String = "argsigma"
	
	private var cache: (
		χ: Buffer<Float>,
		μ: Buffer<Float>,
		σ: Buffer<Float>,
		argμ: Buffer<Float>,
		argσ: Buffer<Float>,
		gradμ: Buffer<Float>,
		gradσ: Buffer<Float>,
		deltaμ: Buffer<Float>,
		deltaσ: Buffer<Float>,
		refresh: ComputePipelineState
	)!
	private var optimizer: Optimizer?
	
	override func setup(context: Context) throws {
		try super.setup(context: context)
		let count: Int = Int(rows*cols)
		optimizer = try context.newOptimizer(count: count)
		cache = (
			χ: context.newBuffer(count: count),
			μ: context.newBuffer(count: count),
			σ: context.newBuffer(count: count),
			argμ: context.newBuffer(count: count),
			argσ: context.newBuffer(count: count),
			gradμ: context.newBuffer(count: count),
			gradσ: context.newBuffer(count: count),
			deltaμ: context.newBuffer(count: count),
			deltaσ: context.newBuffer(count: count),
			refresh: try context.newComputePipelineState(name: "arcaneRefresh")
		)
		setPrimitiveValue(Data(bytesNoCopy: cache.argμ.pointer, count: count, deallocator: .none), forKey: Arcane.argmukey)
		setPrimitiveValue(Data(bytesNoCopy: cache.argσ.pointer, count: count, deallocator: .none), forKey: Arcane.argsigmakey)
	}
	internal func refresh(commandBuffer: CommandBuffer, distribution: SymmetricStableDistribution) {
		func scheduled(commandBuffer: CommandBuffer) {
			willAccessValue(forKey: Arcane.argmukey)
			willAccessValue(forKey: Arcane.argsigmakey)
		}
		func completed(commandBuffer: CommandBuffer) {
			didAccessValue(forKey: Arcane.argmukey)
			didAccessValue(forKey: Arcane.argsigmakey)
		}
		commandBuffer.addScheduledHandler(scheduled)
		commandBuffer.addCompletedHandler(completed)
		commandBuffer.compute {
			$0.set(pipeline: cache.refresh)
			$0.set(buffer: cache.μ, offset: 0, at: 0)
			$0.set(buffer: cache.σ, offset: 0, at: 1)
			$0.set(buffer: cache.gradμ, offset: 0, at: 2)
			$0.set(buffer: cache.gradσ, offset: 0, at: 3)
			$0.set(buffer: cache.argμ, offset: 0, at: 4)
			$0.set(buffer: cache.argσ, offset: 0, at: 5)
			$0.dispatch(groups: (rows*cols-1)/4+1, threads: 1)
		}
		distribution.eval(commandBuffer: commandBuffer, χ: cache.χ, μ: cache.μ, σ: cache.σ)
	}
	internal func update(commandBuffer: CommandBuffer, Δμ: LaObjet<Float>, Δσ: LaObjet<Float>) {
		func scheduled(commandBuffer: CommandBuffer) {
			willChangeValue(forKey: Arcane.argmukey)
			willChangeValue(forKey: Arcane.argsigmakey)
		}
		func completed(commandBuffer: CommandBuffer) {
			didChangeValue(forKey: Arcane.argsigmakey)
			didChangeValue(forKey: Arcane.argmukey)
		}
		commandBuffer.addScheduledHandler(scheduled)
		commandBuffer.addCompletedHandler(completed)
		
		assert(Δμ.copy(to: cache.deltaμ.address))
		optimizer?.update(commandBuffer: commandBuffer, value: cache.argμ, nabla: cache.gradμ, delta: cache.deltaμ)
		
		assert(Δσ.copy(to: cache.deltaσ.address))
		optimizer?.update(commandBuffer: commandBuffer, value: cache.argσ, nabla: cache.gradσ, delta: cache.deltaσ)
		
	}
    internal var χ: LaObjet<Float> {
        return LaObjet<Float>(valuer: cache.χ.address, rows: rows, cols: cols, deallocator: nil)
    }
    internal var μ: LaObjet<Float> {
        return LaObjet<Float>(valuer: cache.μ.address, rows: rows, cols: cols, deallocator: nil)
    }
    internal var σ: LaObjet<Float> {
        return LaObjet<Float>(valuer: cache.σ.address, rows: rows, cols: cols, deallocator: nil)
	}
	internal func dump(label: String? = nil) {
		if let label: String = label {
			print(label)
		}
		print("χ")
		for row in 0..<rows {
			print(Array(cache.χ.buffer[Int(row*cols)..<Int((row+1)*cols)]))
		}
		print("argμ")
		for row in 0..<rows {
			print(Array(cache.argμ.buffer[Int(row*cols)..<Int((row+1)*cols)]))
		}
		print("argσ")
		for row in 0..<rows {
			print(Array(cache.argσ.buffer[Int(row*cols)..<Int((row+1)*cols)]))
		}
	}
}
extension Arcane {
	@NSManaged var rows: UInt
	@NSManaged var cols: UInt
	@NSManaged var argmu: Data
	@NSManaged var argsigma: Data
}
extension Arcane {
	internal func resize(rows: UInt, cols: UInt) throws {
		let count: Int = MemoryLayout<Float>.size*Int(rows*cols)
		self.rows = rows
		self.cols = cols
		self.argmu = Data(count: count)
		self.argsigma = Data(count: count)
		try setup(context: context)
	}
}
