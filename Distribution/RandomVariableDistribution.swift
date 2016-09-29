//
//  Distribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import LaObjet
import Maschine

public protocol RandomVariableDistribution {
	func rng(commandBuffer: CommandBuffer, χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
}
