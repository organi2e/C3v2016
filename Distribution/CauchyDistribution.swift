//
//  CauchyDistribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//

import Accelerate
import LaObjet
import Maschine

public class CauchyDistribution: SymmetricStableDistribution {
	public init() {
		
	}
	public func eval(commandBuffer: CommandBuffer, pdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
	
	}
	public func eval(commandBuffer: CommandBuffer, cdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
	
	}
	public func rng(commandBuffer: CommandBuffer, χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		
	}
	public func λsynth(λ: Buffer<Float>, σ: Buffer<Float>) {
		var count: Int32 = Int32(min(λ.count, σ.count))
		assert(count==Int32(λ.count))
		assert(count==Int32(σ.count))
		vvrecf(λ.address, σ.address, &count)
	}
	public func σscale(σ: LaObjet) -> LaObjet {
		return σ
	}
	public func gradσδ(λ: LaObjet, a: LaObjet, x: LaObjet) -> LaObjet {
		return outer_product(λ * λ, x)
	}
	public func gradσδ(λ: LaObjet, b: LaObjet, y: LaObjet) -> LaObjet {
		return outer_product(λ * λ, y)
	}
	public func gradσδ(λ: LaObjet, c: LaObjet) -> LaObjet {
		return LaMatrice(diagonale: λ * λ, shift: 0)
	}
	public func J(gradμ: Buffer<Float>, gradσ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>) {
		
	}
	public func gradσB(λ: LaObjet, b: LaObjet, y: LaObjet, dy: LaObjet) -> LaObjet {
		return b * outer_product(λ * λ, dy)
	}
}
