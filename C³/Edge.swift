//
//  Edge.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import LaObjet
import Funktion
import CoreData
class Edge: Arcane {
	internal func collect(ignore: Set<Cell>) -> (χ: LaObjet, μ: LaObjet, σ: LaObjet) {
		let activator: LaObjet = input.collect(ignore: ignore)
		let distribution = output.distribution
		return(
			χ: matrix_product(χ, activator),
			μ: matrix_product(μ, distribution.μscale(activator)),
			σ: matrix_product(σ, distribution.σscale(activator))
		)
	}
	internal func correct(ignore: Set<Cell>, activator: LaObjet) -> LaObjet {
		let (Δ: LaObjet, gradμ: LaObjet, gradσ: LaObjet) = output.correct(ignore: ignore)
		return (
			χ: matrix_product(χ, activator)
		)
	}
}
extension Edge {
	@NSManaged var input: Cell
	@NSManaged var output: Cell
}
