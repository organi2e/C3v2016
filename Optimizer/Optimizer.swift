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
	func update(commandBuffer: CommandBuffer, value: Buffer<Float>, nabla: Buffer<Float>, delta: Buffer<Float>)
	func reset()
}
