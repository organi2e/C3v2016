//
//  StableDistribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//

import Maschine
import LaObjet

public protocol SymmetricStableDistribution: RandomNumberGenerator {
	func eval(commandBuffer: CommandBuffer, pdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
	func eval(commandBuffer: CommandBuffer, cdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
	func eval(commandBuffer: CommandBuffer, dχdμ: Buffer<Float>, dχdλ: Buffer<Float>, λ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
	func eval(commandBuffer: CommandBuffer, gradμ: Buffer<Float>, gradλ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>)
	func synth(λ: Buffer<Float>, σ: Buffer<Float>)
	func scale<Type: FloatingPoint>(μ: LaObjet<Type>) -> LaObjet<Type>
	func scale<Type: FloatingPoint>(σ: LaObjet<Type>) -> LaObjet<Type>
	func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, a: LaObjet<Type>, x: LaObjet<Type>) -> LaObjet<Type>
	func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, b: LaObjet<Type>, y: LaObjet<Type>) -> LaObjet<Type>
	func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, c: LaObjet<Type>) -> LaObjet<Type>
	func gradσB<Type: FloatingPoint>(λ: LaObjet<Type>, b: LaObjet<Type>, y: LaObjet<Type>, dy: LaObjet<Type>) -> LaObjet<Type>
}
