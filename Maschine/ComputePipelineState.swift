//
//  ComputePipelineState.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public typealias ComputePipelineState = MTLComputePipelineState

extension Maschine {
	public func newComputePipelineState(name: String) throws -> ComputePipelineState {
		guard let funktion: Funktion = cache.funktion[name] else {
			throw Fehler.NichtGefunden(funktion: name)
		}
		return try device.makeComputePipelineState(function: funktion)
	}
}
