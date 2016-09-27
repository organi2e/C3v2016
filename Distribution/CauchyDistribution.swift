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

internal class CauchyDistribution: StrictlyStableDistribution {
	func pdf(value: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		
	}
	func cdf(value: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		
	}
	func rng(value: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		
	}
	func λsynth(λ: Buffer<Float>, σ: Buffer<Float>) {
		var count: Int32 = Int32(min(λ.count, σ.count))
		assert(count==Int32(λ.count))
		assert(count==Int32(σ.count))
		vvrecf(λ.address, σ.address, &count)
	}
	func σscale(σ: LaObjet) -> LaObjet {
		return σ
	}
	func δ(λ: LaObjet, a: LaObjet, x: LaObjet) -> LaObjet {
		return outer_product(λ * λ, x)
	}
	func δ(λ: LaObjet, b: LaObjet, y: LaObjet) -> LaObjet {
		return outer_product(λ * λ, y)
	}
	func δ(λ: LaObjet, c: LaObjet) -> LaObjet {
		return LaMatrice(diagonale: λ * λ, shift: 0)
	}
	func J(gradμ: Buffer<Float>, gradσ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		
	}
	func B(λ: LaObjet, b: LaObjet, y: LaObjet, dy: LaObjet) -> LaObjet {
		return b * outer_product(λ * λ, dy)
	}
}
