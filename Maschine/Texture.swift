//
//  Texture.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public typealias Texture = MTLTexture

extension Maschine {
	public func newTexture(configure: (MTLTextureDescriptor)->MTLTextureDescriptor) -> Texture {
		return device.makeTexture(descriptor: configure(MTLTextureDescriptor()))
	}
}
