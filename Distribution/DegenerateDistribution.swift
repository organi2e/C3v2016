//
//  DegenerateDistribution.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import LaObjet
import Maschine

public class DegenerateDistribution: SymmetricStableDistribution {
	public func rng(commandBuffer: CommandBuffer, χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		assert(LaObjet<Float>(valuer: μ.address, rows: μ.count, cols: 1).copy(buffer: χ.address))
	}
	public func eval(commandBuffer: CommandBuffer, pdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		LaObjet<Float>(valuer: 1, rows: μ.count, cols: 1).copy(to: μ.address)
	}
	public func eval(commandBuffer: CommandBuffer, cdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
	
	}
	public func eval(commandBuffer: CommandBuffer, gradμ: Buffer<Float>, gradσ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>) {
	
	}
	public func λsynth(λ: Buffer<Float>, σ: Buffer<Float>) {
	
	}
	public func σscale<Type: FloatingPoint>(σ: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0, rows: σ.rows, cols: σ.cols)
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, a: LaObjet<Type>, x: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0)
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, b: LaObjet<Type>, y: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0)
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, c: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0)
	}
	public func gradσB<Type: FloatingPoint>(λ: LaObjet<Type>, b: LaObjet<Type>, y: LaObjet<Type>, dy: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0)
	}
}
