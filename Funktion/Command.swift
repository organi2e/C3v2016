//
//  Command.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//

import Metal

public typealias ComputeCommandEncoder = MTLComputeCommandEncoder
public typealias BlitCommandEncoder = MTLBlitCommandEncoder

public class Command {
	
	typealias CommandBuffer = MTLCommandBuffer
	
	let buffer: CommandBuffer
	let maschine: Maschine
	
	internal init(buffer: CommandBuffer, maschine: Maschine) {
		self.buffer = buffer
		self.maschine = maschine
	}
	
	func newCompute(funktion: String, handler: (ComputeCommandEncoder) -> Void ) {
		if let funktion: Funktion = maschine.funktions[funktion] {
			func complete(state: ComputePipelineState) {
				let encoder: ComputeCommandEncoder = buffer.makeComputeCommandEncoder()
				encoder.setComputePipelineState(state)
				encoder.endEncoding()
			}
			buffer.device.makeComputePipelineState(function: funktion) {
				if let state: ComputePipelineState = $0.0 {
					complete(state: state)
				}
			}
		}
	}
	func newBlit(handler: (BlitCommandEncoder) -> Void) {
		let encoder: BlitCommandEncoder = buffer.makeBlitCommandEncoder()
		handler(encoder)
		encoder.endEncoding()
	}
	func commit() {
		buffer.commit()
	}
	func enque() {
		buffer.enqueue()
	}
	func addCompleteHandler(block: @escaping (CommandBuffer)->Void) {
		buffer.addCompletedHandler {
			block($0)
		}
	}
}

extension Maschine {
	public func newCommand() -> Command {
		return Command(buffer: queue.makeCommandBuffer(), maschine: self)
	}
}
