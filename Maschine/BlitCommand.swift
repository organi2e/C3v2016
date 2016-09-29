//
//  BlitCommand.swift
//  C³
//
//  Created by Kota Nakano on 9/29/16.
//
//

import Metal

public typealias BlitCommand = MTLBlitCommandEncoder

extension BlitCommand {
	public func copy<T>(destination: Buffer<T>, destinationOffset: Int? = nil, source: Buffer<T>, sourceOffset: Int? = nil, size: Int? = nil) {
		let sloc: Int = sourceOffset ?? 0
		let dloc: Int = destinationOffset ?? 0
		copy(from: source.body, sourceOffset: sloc, to: destination.body, destinationOffset: dloc, size: size ?? min(source.length - sloc, destination.length - dloc))
	}
	public func fill<T>(buffer: Buffer<T>, value: UInt8, location: Int? = nil, length: Int? = nil) {
		let loc: Int = location ?? 0
		let len: Int = length ?? ( buffer.length - loc )
		fill(buffer: buffer.body, range: NSRange(location: loc, length: len), value: value)
	}
	public func sync<T>(buffer: Buffer<T>) {
		synchronize(resource: buffer.body)
	}
}
