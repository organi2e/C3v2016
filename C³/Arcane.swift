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
	
	private static let keys: (λμ: String, λσ: String) = (λμ: "lambdamu", λσ: "lambdasigma")
	
	private var cache: (
		χ: Buffer<Float>,
		μ: Buffer<Float>,
		σ: Buffer<Float>,
		λμ: Buffer<Float>,
		λσ: Buffer<Float>,
		Δμ: Buffer<Float>,
		Δσ: Buffer<Float>,
		refresh: ComputePipelineState
	)!
	private var lock: DispatchGroup = DispatchGroup()
	private var optimizer: Optimizer?
	
	override func setup(context: Context) throws {
		try super.setup(context: context)
		let count: Int = Int(rows*cols)
		optimizer = try context.newOptimizer(count: count)
		cache = (
			χ: context.newBuffer(count: count),
			μ: context.newBuffer(count: count),
			σ: context.newBuffer(count: count),
			λμ: context.newBuffer(count: count),
			λσ: context.newBuffer(count: count),
			Δμ: context.newBuffer(count: count),
			Δσ: context.newBuffer(count: count),
			refresh: try context.newComputePipelineState(name: "arcaneRefresh")
		)
		setPrimitiveValue(Data(bytesNoCopy: cache.λμ.pointer, count: count, deallocator: .none), forKey: Arcane.keys.λμ)
		setPrimitiveValue(Data(bytesNoCopy: cache.λσ.pointer, count: count, deallocator: .none), forKey: Arcane.keys.λσ)
	}
	internal func refresh(commandBuffer: CommandBuffer, distribution: SymmetricStableDistribution) {
		
		func scheduled(commandBuffer: CommandBuffer) {
			willAccessValue(forKey: Arcane.keys.λμ)
			willAccessValue(forKey: Arcane.keys.λσ)
			lock.enter()
		}
		
		func completed(commandBuffer: CommandBuffer) {
			lock.leave()
			didAccessValue(forKey: Arcane.keys.λμ)
			didAccessValue(forKey: Arcane.keys.λσ)
		}
		
		//lock.wait()
		
		commandBuffer.addScheduledHandler(scheduled)
		commandBuffer.addCompletedHandler(completed)
		
		commandBuffer.compute {
			$0.set(pipeline: cache.refresh)
			$0.set(buffer: cache.μ, offset: 0, at: 0)
			$0.set(buffer: cache.σ, offset: 0, at: 1)
			$0.set(buffer: cache.Δμ, offset: 0, at: 2)
			$0.set(buffer: cache.Δσ, offset: 0, at: 3)
			$0.set(buffer: cache.λμ, offset: 0, at: 4)
			$0.set(buffer: cache.λσ, offset: 0, at: 5)
			$0.dispatch(groups: (rows*cols-1)/4+1, threads: 1)
		}
		
		distribution.eval(commandBuffer: commandBuffer, χ: cache.χ, μ: cache.μ, σ: cache.σ)
	}
	internal func update(commandBuffer: CommandBuffer, Δμ: LaObjet<Float>, Δσ: LaObjet<Float>) {
		
		func scheduled(commandBuffer: CommandBuffer) {
			willChangeValue(forKey: Arcane.keys.λμ)
			willChangeValue(forKey: Arcane.keys.λσ)
			lock.enter()
		}
		
		func completed(commandBuffer: CommandBuffer) {
			lock.leave()
			didChangeValue(forKey: Arcane.keys.λμ)
			didChangeValue(forKey: Arcane.keys.λσ)
		}
		
		commandBuffer.addScheduledHandler(scheduled)
		commandBuffer.addCompletedHandler(completed)
		
		assert(Δμ.count==UInt(cache.Δμ.count))
		assert(Δσ.count==UInt(cache.Δσ.count))
		
		let dμdλ: LaObjet<Float> = LaObjet(valuer: cache.Δμ.address, rows: Δμ.rows, cols: Δμ.cols, deallocator: nil)
		let dσdλ: LaObjet<Float> = LaObjet(valuer: cache.Δσ.address, rows: Δσ.rows, cols: Δσ.cols, deallocator: nil)
		
		lock.wait()
		
		assert((Δμ*dμdλ).copy(to: cache.Δμ.address))
		assert((Δσ*dσdλ).copy(to: cache.Δσ.address))
		
		optimizer?.update(commandBuffer: commandBuffer, value: cache.λμ, delta: cache.Δμ)
		optimizer?.update(commandBuffer: commandBuffer, value: cache.λσ, delta: cache.Δσ)
		
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
		print("λμ")
		for row in 0..<rows {
			print(Array(cache.λμ.buffer[Int(row*cols)..<Int((row+1)*cols)]))
		}
		print("λσ")
		for row in 0..<rows {
			print(Array(cache.λσ.buffer[Int(row*cols)..<Int((row+1)*cols)]))
		}
	}
}
extension Arcane {
	
}
extension Arcane {
	@NSManaged var rows: UInt
	@NSManaged var cols: UInt
	@NSManaged var lambdamu: Data
	@NSManaged var lambdasigma: Data
}
extension Arcane {
	internal func resize(rows: UInt, cols: UInt) throws {
		let count: Int = MemoryLayout<Float>.size*Int(rows*cols)
		self.rows = rows
		self.cols = cols
		self.lambdamu = Data(count: count)
		self.lambdasigma = Data(count: count)
		try setup(context: context)
	}
}
