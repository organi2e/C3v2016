//
//  Sampler.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public typealias Sampler = MTLSamplerState

extension Sampler {

}

extension Maschine {
	public func newSampler(configure:(MTLSamplerDescriptor)->MTLSamplerDescriptor) -> Sampler {
		return device.makeSamplerState(descriptor: configure(MTLSamplerDescriptor()))
	}
}
