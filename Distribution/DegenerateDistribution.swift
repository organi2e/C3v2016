//
//  DegenerateDistribution.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Accelerate
import LaObjet
import Maschine

public class DegenerateDistribution: SymmetricStableDistribution {
	public init(maschine: Maschine, count: Int) {
	
	}
	public func eval(commandBuffer: CommandBuffer, pdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
	
	}
	public func eval(commandBuffer: CommandBuffer, cdf: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
	
	}
	public func rng(commandBuffer: CommandBuffer, χ: Buffer<Float>, μ: Buffer<Float>, σ: Buffer<Float>) {
		commandBuffer.blit {
			$0.copy(destination: χ, source: μ)
		}
	}
    public func λsynth(λ: Buffer<Float>, σ: Buffer<Float>) {
		assert(Data(bytesNoCopy: σ.pointer, count: σ.length, deallocator: .none).copyBytes(to: λ.buffer)==λ.count)
	}
    public func σscale(σ: LaObjet) -> LaObjet {
        return LaMatrice(valuer: 0)
    }
    public func gradσδ(λ: LaObjet, a: LaObjet, x: LaObjet) -> LaObjet {
        return LaMatrice(valuer: 0)
    }
    public func gradσδ(λ: LaObjet, b: LaObjet, y: LaObjet) -> LaObjet {
        return LaMatrice(valuer: 0)
    }
    public func gradσδ(λ: LaObjet, c: LaObjet) -> LaObjet {
        return LaMatrice(valuer: 0)
    }
    public func J(gradμ: Buffer<Float>, gradσ: Buffer<Float>, μ: Buffer<Float>, λ: Buffer<Float>) {
		
    }
    public func gradσB(λ: LaObjet, b: LaObjet, y: LaObjet, dy: LaObjet) -> LaObjet {
        return LaMatrice(valuer: 0)
    }
}
