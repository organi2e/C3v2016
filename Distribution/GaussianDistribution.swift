//
//  GaussianDistribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//

import LaObjet
import Maschine

private let M_SQRT1_2PI = Float(0.5*M_SQRT1_2*M_2_SQRTPI)

public class GaussianDistribution: SymmetricStableDistribution {
	let u: Buffer<uint>
	let rng: ComputePipelineState
	let grn: ComputePipelineState
	public init(maschine: Maschine, block: Int = 256) throws {
		try?maschine.employ(bundle: Bundle(for: type(of: self)))
		u = maschine.newBuffer(count: block, options: .cpuCacheModeWriteCombined)
		rng = try maschine.newComputePipelineState(name: "gaussRng")
		grn = try maschine.newComputePipelineState(name: "gaussGrn")
	}
	public func eval(commandBuffer: CommandBuffer, pdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		
	}
	public func eval(commandBuffer: CommandBuffer, cdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)	{
	
	}
	public func eval(commandBuffer: CommandBuffer, χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		let count: Int = min(χ.count, μ.count, σ.count)
		assert(χ.count==count)
		assert(μ.count==count)
		assert(σ.count==count)
		arc4random_buf(u.pointer, u.length)
		commandBuffer.compute {
			$0.set(pipeline: rng)
			$0.set(buffer: χ, offset: 0, at: 0)
			$0.set(buffer: μ, offset: 0, at: 1)
			$0.set(buffer: σ, offset: 0, at: 2)
			$0.set(buffer: u, offset: 0, at: 3)
			$0.set(array: [uint(13), uint(17), uint(5), uint((count-1)/4+1)], at: 4)
			$0.dispatch(groups: u.count/4, threads: 1)
		}
	}
	public func eval(commandBuffer: CommandBuffer, dχdμ: Buffer<Float>, dχdλ: Buffer<Float>, λ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		assert(LaObjet<Float>(valuer: 1, rows: μ.count, cols: 1).copy(to: dχdμ.address))
		assert(LaObjet<Float>(valuer: 0, rows: σ.count, cols: 1).copy(to: dχdλ.address))
		assert(LaObjet<Float>(valuer: 0, rows: σ.count, cols: 1).copy(to: λ.address))
	}
	public func eval(commandBuffer: CommandBuffer, gradμ: Buffer<Float>, gradλ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>) {
		let count: Int = min(gradμ.count, gradλ.count, μ.count, λ.count)
		assert(gradμ.count==count)
		assert(gradλ.count==count)
		assert(μ.count==count)
		assert(λ.count==count)
		commandBuffer.compute {
			$0.set(pipeline: grn)
			$0.set(buffer: gradμ, offset: 0, at: 0)
			$0.set(buffer: gradλ, offset: 0, at: 1)
			$0.set(buffer: μ, offset: 0, at: 2)
			$0.set(buffer: λ, offset: 0, at: 3)
			$0.set(value: M_SQRT1_2PI, at: 4)
			$0.dispatch(groups: (count-1)/4+1, threads: 1)
		}
	}
	public func synth(λ: Buffer<Float>, σ: Buffer<Float>) {
		var count: Int32 = Int32(min(λ.count, σ.count))
		assert(count==Int32(λ.count))
		assert(count==Int32(σ.count))
		Float.vecteurRsqrt(λ.address, σ.address, &count)
	}
	public func scale<T: FloatingPoint>(μ: LaObjet<T>) -> LaObjet<T> {
		return μ
	}
	public func scale<T: FloatingPoint>(σ: LaObjet<T>) -> LaObjet<T> {
		return σ * σ
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, a: LaObjet<Type>, x: LaObjet<Type>) -> LaObjet<Type> {
		return a * outer_product(λ * λ * λ, x * x)
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, b: LaObjet<Type>, y: LaObjet<Type>) -> LaObjet<Type> {
		return b * outer_product(λ * λ * λ, y * y)
	}
	public func gradσδ<Type: FloatingPoint>(λ: LaObjet<Type>, c: LaObjet<Type>) -> LaObjet<Type> {
		return LaObjet(diagonale: λ * λ * λ * c, shift: 0)
	}
	public func gradσB<Type: FloatingPoint>(λ: LaObjet<Type>, b: LaObjet<Type>, y: LaObjet<Type>, dy: LaObjet<Type>) -> LaObjet<Type> {
		return b * b * outer_product(λ * λ * λ, y * dy)
	}
}

