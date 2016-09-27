//
//  Momentum.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import LaObjet

public class Momentum {
	private static let η: Float = 0.5
	private static let γ: Float = 0.9
	private let γ: Float
	private let η: Float
	private let w: [Float]
	private var W: LaObjet {
		return LaMatrice(valuer: w, rows: w.count, cols: 1, deallocator: nil)
	}
	init(dim: Int, γ: Float = γ, η: Float = η) {
		self.γ = γ
		self.η = η
		self.w = [Float](repeating: 0, count: dim)
	}
	static func factory(γ: Float = γ, η: Float = η) -> (Int) -> Optimizer {
		return {
			Momentum(dim: $0, γ: γ, η: η)
		}
	}
	public func optimize(Δx: LaObjet, x: LaObjet) -> LaObjet {
		assert((γ * W + η * Δx).getBytes(buffer: w))
		return W
	}
}
extension Momentum: Optimizer {
	public func reset() {
	//	vDSP_vclr(UnsafeMutablePointer<Float>(w), 1, vDSP_Length(w.count))
	}
}
