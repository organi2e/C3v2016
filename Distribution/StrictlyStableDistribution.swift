//
//  StableDistribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//

import Maschine
import LaObjet

protocol StrictlyStableDistribution: Distribution {
	func pdf(value: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
	func cdf(value: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
	func rng(value: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
	func λsynth(λ: Buffer<Float>, σ: Buffer<Float>)
	func σscale(σ: LaObjet) -> LaObjet
	func δ(λ: LaObjet, a: LaObjet, x: LaObjet) -> LaObjet
	func δ(λ: LaObjet, b: LaObjet, y: LaObjet) -> LaObjet
	func δ(λ: LaObjet, c: LaObjet) -> LaObjet
	func J(gradμ: Buffer<Float>, gradσ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>)
	func B(λ: LaObjet, b: LaObjet, y: LaObjet, dy: LaObjet) -> LaObjet
}
