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

internal class Arcane: ManagedObject {
	
	private static let argmukey: String = "argmu"
	private static let argsigmakey: String = "argsigma"
	private static let keys: Set<String> = Set<String>(arrayLiteral: argmukey, argsigmakey)
	
	private var cache: (
		χ: Buffer<Float>,
		μ: Buffer<Float>,
		σ: Buffer<Float>,
		argμ: Buffer<Float>,
		argσ: Buffer<Float>,
		graμ: Buffer<Float>,
		graσ: Buffer<Float>,
		refresh: ComputePipelineState
	)!
	private var optimizer: Optimizer!
	
	override func setup(context: Context) throws {
		let count: Int = Int(rows*cols)
		cache = (
			χ: context.newBuffer(count: count),
			μ: context.newBuffer(count: count),
			σ: context.newBuffer(count: count),
			argμ: context.newBuffer(count: count),
			argσ: context.newBuffer(count: count),
			graμ: context.newBuffer(count: count),
			graσ: context.newBuffer(count: count),
			refresh: try context.newComputePipelineState(name: "arcaneRefresh")
		)
		setPrimitiveValue(Data(bytesNoCopy: cache.argμ.pointer, count: count, deallocator: .none), forKey: Arcane.argmukey)
		setPrimitiveValue(Data(bytesNoCopy: cache.argσ.pointer, count: count, deallocator: .none), forKey: Arcane.argsigmakey)
	}
	internal func refresh(commandBuffer: CommandBuffer) {
		func scheduled(commandBuffer: CommandBuffer) {
			Arcane.keys.forEach { willAccessValue(forKey: $0) }
		}
		func completed(commandBuffer: CommandBuffer) {
			Arcane.keys.forEach { didAccessValue(forKey: $0) }
		}
		commandBuffer.addScheduledHandler(scheduled)
		commandBuffer.addCompletedHandler(completed)
	}
	internal func update(commandBuffer: CommandBuffer, Δμ: Buffer<Float>, Δσ: Buffer<Float>) {
		
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
}
extension Arcane {
	@NSManaged var rows: UInt
	@NSManaged var cols: UInt
	@NSManaged var argmu: Data
	@NSManaged var argsigma: Data
}
extension Arcane {
	func resize(rows: UInt, cols: UInt) {
		let count: Int = Int(rows*cols)
		self.rows = rows
		self.cols = cols
		self.argmu = Data(count: MemoryLayout<Float>.size*count)
		self.argsigma = Data(count: MemoryLayout<Float>.size*count)
	}
}
