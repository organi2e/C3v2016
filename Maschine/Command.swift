//
//  Command.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public typealias Command = MTLCommandBuffer

extension Command {
	public func compute(configure: (ComputeCommand)->Void) {
		let computeCommand: ComputeCommand = makeComputeCommandEncoder()
		configure(computeCommand)
		computeCommand.close()
	}
}
extension Maschine {
	public func newCommand() -> Command {
		return commandQueue.makeCommandBuffer()
	}
}
