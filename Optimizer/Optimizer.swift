//
//  Optimizer.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import LaObjet
import Maschine

public protocol Optimizer {
	func update(commandBuffer: CommandBuffer, θ: Buffer<Float>, Δθ: Buffer<Float>)
	func reset()
}
