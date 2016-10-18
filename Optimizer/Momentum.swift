//
//  Momentum.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Maschine

public class Momentum {
	
	private static let η: Float = 0.5
	private static let γ: Float = 0.9
	
	private let η: Float
	private let γ: Float
	
	private let pipeline: ComputePipelineState
	private let velocity: Buffer<Float>
	private let group: Int
	
	public init(maschine: Maschine, count: Int, γ: Float = γ, η: Float = η) throws {
		try?maschine.employ(bundle: Bundle(for: type(of: self)))
		self.pipeline = try maschine.newComputePipelineState(name: "Momentum")
		self.velocity = maschine.newBuffer(count: count)
		self.group = (count-1)/4+1
		self.γ = γ
		self.η = η
	}
	public func update(commandBuffer: CommandBuffer, value: Buffer<Float>, delta: Buffer<Float>) {
		commandBuffer.compute {
			$0.set(pipeline: pipeline)
			$0.set(buffer: value, offset: 0, at: 0)
			$0.set(buffer: delta, offset: 0, at: 1)
			$0.set(buffer: velocity, offset: 0, at: 2)
			$0.set(value: γ, at: 3)
			$0.set(value: η, at: 4)
			$0.dispatch(groups: group, threads: 1)
		}
	}
	public func reset() {
		
	}
}
extension Momentum: Optimizer {
}
