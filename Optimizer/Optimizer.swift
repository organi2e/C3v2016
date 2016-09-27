//
//  Optimizer.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import LaObjet
import Funktion

public class op {
	func optimize(x: Buffer, Δx: Buffer)
}

public protocol Optimizer {
	func optimize(Δx: LaObjet, x: LaObjet) -> LaObjet
	func reset()
}

public class SGD {
	
	private static let η: Float = 0.5
	
	internal let η: Float
	
	init(η n: Float = η) {
		η = n
	}
	static func factory(η: Float = η) -> (Int) -> Optimizer {
		return {(_) -> Optimizer in
			SGD(η: η)
		}
	}
}

extension SGD: Optimizer {
	public func optimize(Δx: LaObjet, x: LaObjet) -> LaObjet {
		return η * Δx
	}
	public func reset() {
		
	}
}
