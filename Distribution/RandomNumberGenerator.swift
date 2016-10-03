//
//  Distribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import Maschine

public protocol RandomNumberGenerator {
	func eval(commandBuffer: CommandBuffer, χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
}
