//
//  CauchyDistribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import LaObjet
import Funktion
public class CauchyDistribution: StrictlyStableDistribution {
	//let rng: ComputePipelineState
	private let r: Buffer
	private let mu: Buffer
	private let sigma: Buffer
	public init(machine: Maschine, count: Int) {
		do {
			try machine.loadLibraryFrom(bundle: Bundle(for: type(of: self)))
		} catch FunktionError.NichtGefunden(let funktion) {
			assertionFailure("\(funktion) is not found")
		} catch FunktionError.BereitsRegistriert {
			//nop
		} catch {
			
		}
		let Δx: Int = 0
		r = machine.newBuffer(length: MemoryLayout<Float>.size*count)
		mu = machine.newBuffer(length: MemoryLayout<Float>.size*count)
		sigma = machine.newBuffer(length: MemoryLayout<Float>.size*count)
	}
	public var μ: LaObjet {
		return LaMatrice(valuer: 0)
	}
	public var σ: LaObjet {
		return LaMatrice(valuer: 0)
	}
	public func pdf(value: Buffer) {
		
	}
	public func cdf(value: Buffer) {
		
	}
	public func shuffle() {
		
	}
	public var value: LaObjet {
		return LaMatrice(valuer: 0)
	}
	public func μscale(μ: LaObjet) -> LaObjet {
		return μ
	}
	public func σscale(σ: LaObjet) -> LaObjet {
		return σ
	}
	public func gradμscale(μ: LaObjet) -> LaObjet {
		return LaMatrice(valuer: 1)
	}
	public func gradσscale(σ: LaObjet) -> LaObjet {
		return LaMatrice(valuer: 1)
	}
}
