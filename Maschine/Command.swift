//
//  Command.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public typealias CommandBuffer = MTLCommandBuffer

extension CommandBuffer {
	public func compute(encode: (ComputeCommand)->Void) {
		let computeCommand: ComputeCommand = makeComputeCommandEncoder()
		encode(computeCommand)
		computeCommand.endEncoding()
	}
	public func blit(encode: (BlitCommand)->Void) {
		let blitCommand: BlitCommand = makeBlitCommandEncoder()
		encode(blitCommand)
		blitCommand.endEncoding()
	}
}
extension Maschine {
	public func newCommandBuffer() -> CommandBuffer {
		return commandQueue.makeCommandBuffer()
	}
}

public typealias Command = MTLCommandEncoder
extension Command {
	public func close() {
		endEncoding()
	}
	public func insert(sign: String) {
		insertDebugSignpost(sign)
	}
	public func push(group: String) {
		pushDebugGroup(group)
	}
	public func pop() {
		popDebugGroup()
	}
}
