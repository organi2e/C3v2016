//
//  RMSProp.swift
//  C³
//
//  Created by Kota on 10/4/16.
//
//

import Maschine

public class RMSProp: Optimizer {
	
	let groups: Int
	let α: Float
	let γ: Float
	let ε: Float
	let r: Buffer<Float>
	let pipeline: ComputePipelineState
	
	public static func factory(α: Float, γ: Float, ε: Float) -> (Maschine, Int) throws -> Optimizer {
		return {
			try RMSProp(maschine: $0, count: $1, α: α, γ: γ, ε: ε)
		}
	}
	
	public init(maschine: Maschine, count: Int, α: Float, γ: Float, ε: Float) throws {
		try?maschine.employ(bundle: Bundle(for: type(of: self)))
		self.pipeline = try maschine.newComputePipelineState(name: "RMSProp")
		self.r = maschine.newBuffer(count: count)
		self.α = α
		self.γ = γ
		self.ε = ε
		self.groups = (count-1)/4+1
	}
	
	public func update(commandBuffer: CommandBuffer, value: Buffer<Float>, delta: Buffer<Float>) {
		commandBuffer.compute {
			$0.set(pipeline: pipeline)
			$0.set(buffer: value, offset: 0, at: 0)
			$0.set(buffer: delta, offset: 0, at: 1)
			$0.set(buffer: r, offset: 0, at: 2)
			$0.set(value: α, at: 3)
			$0.set(value: γ, at: 4)
			$0.set(value: ε, at: 5)
			$0.dispatch(groups: groups, threads: 1)
		}
	}
	public func reset() {
		
	}
}
