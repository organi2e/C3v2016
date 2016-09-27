//
//  ComputeCommand.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public typealias ComputeCommand = MTLComputeCommandEncoder

public extension ComputeCommand {
	public func close() {
		endEncoding()
	}
	public func set(pipeline: Maschine.ComputePipelineState) {
		setComputePipelineState(pipeline)
	}
	public func set<T>(buffer: Buffer<T>, offset: Int, at: Int) {
		setBuffer(buffer.body, offset: offset, at: at)
	}
	public func set(texture: Texture, at: Int) {
		setTexture(texture, at: at)
	}
	public func set(sampler: Sampler, at: Int) {
		setSamplerState(sampler, at: at)
	}
	public func set<T>(value: T, at: Int) {
		setBytes([value], length: MemoryLayout<T>.size, at: at)
	}
	public func set<T>(array: [T], at: Int) {
		setBytes(array, length: MemoryLayout<T>.size*array.count, at: at)
	}
	public func set(sharedBytes: Int, at: Int) {
		setThreadgroupMemoryLength(sharedBytes, at: at)
	}
	public func dispatch(groups: Int, threads: Int) {
		dispatchThreadgroups(MTLSize(width: groups, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: threads, height: 1, depth: 1))
	}
	public func dispatch(groups: (width: Int, height: Int), threads: (width: Int, height: Int)) {
		dispatchThreadgroups(MTLSize(width: groups.width, height: groups.height, depth: 1), threadsPerThreadgroup: MTLSize(width: threads.width, height: threads.height, depth: 1))
	}
	public func dispatch(groups: (width: Int, height: Int, depth: Int), threads: (width: Int, height: Int, depth: Int)) {
		dispatchThreadgroups(MTLSize(width: groups.width, height: groups.height, depth: groups.depth), threadsPerThreadgroup: MTLSize(width: threads.width, height: threads.height, depth: threads.depth))
	}
	public func push(group: String) {
		pushDebugGroup(group)
	}
	public func pop() {
		popDebugGroup()
	}
}
