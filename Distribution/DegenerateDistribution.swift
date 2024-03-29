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
	public init() {
		
	}
	public func eval(commandBuffer: CommandBuffer, χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		commandBuffer.blit {
			$0.copy(destination: χ, source: μ)
		}
	}
	public func eval(commandBuffer: CommandBuffer, pdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		for k in 0..<pdf.count {
			pdf[k] = 0 == μ[k] ? 1 : 0
		}
	}
	public func eval(commandBuffer: CommandBuffer, cdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		for k in 0..<cdf.count {
			cdf[k] = 0 < μ[k]  ? 1 : 0 > μ[k] ? -1 : 0
		}
	}
	public func eval(commandBuffer: CommandBuffer, dχdμ: Buffer<Float>, dχdλ: Buffer<Float>, λ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		assert(LaObjet<Float>(valuer: 1, rows: μ.count, cols: 1).copy(to: dχdμ.address))
		assert(LaObjet<Float>(valuer: 0, rows: σ.count, cols: 1).copy(to: dχdλ.address))
		assert(LaObjet<Float>(valuer: 0, rows: σ.count, cols: 1).copy(to: λ.address))
	}
	public func eval(commandBuffer: CommandBuffer, gradμ: Buffer<Float>, gradλ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>) {
		assert(LaObjet<Float>(valuer: 1, rows: μ.count, cols: 1).copy(to: gradμ.address))
		assert(LaObjet<Float>(valuer: 0, rows: λ.count, cols: 1).copy(to: gradλ.address))
	}
	public func synth(λ: Buffer<Float>, σ: Buffer<Float>) {
		assert(LaObjet<Float>(valuer: 0, rows: σ.count, cols: 1).copy(to: λ.address))
	}
	public func scale<Type: FloatingPoint>(μ: LaObjet<Type>) -> LaObjet<Type> {
		return μ
	}
	public func scale<Type: FloatingPoint>(σ: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0, rows: σ.rows, cols: σ.cols)
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, a: LaObjet<Type>, x: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0, rows: λ.count, cols: x.count)
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, b: LaObjet<Type>, y: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0, rows: λ.count, cols: b.count)
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, c: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0, rows: λ.count, cols: λ.count)
	}
	public func gradσB<Type: FloatingPoint>(λ: LaObjet<Type>, b: LaObjet<Type>, y: LaObjet<Type>, dy: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet<Type>(valuer: 0, rows: λ.count, cols: λ.count)
	}
}
