//
//  StochasticGradientDescent.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Maschine

public class StochasticGradientDescent: Optimizer {
	
	let groups: Int
	let η: Float
	let pipeline: ComputePipelineState
	
	public init(maschine: Maschine, count: Int, η: Float) throws {
		try?maschine.employ(bundle: Bundle(for: type(of: self)))
		self.pipeline = try maschine.newComputePipelineState(name: "StochasticGradientDescent")
		self.groups = (count-1)/4+1
		self.η = η
	}
	public func update(commandBuffer: CommandBuffer, θ: Buffer<Float>, Δθ: Buffer<Float>) {
		commandBuffer.compute {
			$0.set(pipeline: pipeline)
			$0.set(buffer: θ, offset: 0, at: 0)
			$0.set(buffer: Δθ, offset: 0, at: 1)
			$0.set(value: η, at: 2)
			$0.dispatch(groups: groups, threads: 1)
		}
	}
	public func reset() {
		
	}
}
