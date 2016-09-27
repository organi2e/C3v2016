//
//  StableDistribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import LaObjet
public protocol StrictlyStableDistribution: Distribution {
    var μ: LaObjet { get }
    var σ: LaObjet { get }
    func μscale(μ: LaObjet) -> LaObjet
    func σscale(σ: LaObjet) -> LaObjet
    func gradμscale(μ: LaObjet) -> LaObjet
    func gradσscale(σ: LaObjet) -> LaObjet
}
