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
	public func set(pipeline: Maschine.ComputePipelineState) {
		setComputePipelineState(pipeline)
	}
	public func set<T, I: Integer>(buffer: Buffer<T>, offset: I, at: I) {
		setBuffer(buffer.body, offset: offset.signedValue, at: at.signedValue)
	}
	public func set<I: Integer>(texture: Texture, at: I) {
		setTexture(texture, at: at.signedValue)
	}
	public func set<I: Integer>(sampler: Sampler, at: I) {
		setSamplerState(sampler, at: at.signedValue)
	}
	public func set<T>(value: T, at: Int) {
		setBytes([value], length: MemoryLayout<T>.size, at: at.signedValue)
	}
	public func set<T>(array: [T], at: Int) {
		setBytes(array, length: MemoryLayout<T>.size*array.count, at: at.signedValue)
	}
	public func set<L: Integer, I: Integer>(sharedBytes: L, at: I) {
		setThreadgroupMemoryLength(sharedBytes.signedValue, at: at.signedValue)
	}
	public func dispatch<I: Integer>(groups: I, threads: I) {
		dispatchThreadgroups(MTLSize(width: groups.signedValue, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: threads.signedValue, height: 1, depth: 1))
	}
	public func dispatch<I: Integer>(groups: (width: I, height: I), threads: (width: I, height: I)) {
		dispatchThreadgroups(MTLSize(width: groups.width.signedValue, height: groups.height.signedValue, depth: 1), threadsPerThreadgroup: MTLSize(width: threads.width.signedValue, height: threads.height.signedValue, depth: 1))
	}
	public func dispatch<I: Integer>(groups: (width: I, height: I, depth: I), threads: (width: I, height: I, depth: I)) {
		dispatchThreadgroups(MTLSize(width: groups.width.signedValue, height: groups.height.signedValue, depth: groups.depth.signedValue), threadsPerThreadgroup: MTLSize(width: threads.width.signedValue, height: threads.height.signedValue, depth: threads.depth.signedValue))
	}
}

private extension Integer {
	var signedValue: Int {
		switch self {
		case let value as Int: return value
		case let value as UInt: return Int(value)
		case let value as Int8: return Int(value)
		case let value as UInt8: return Int(value)
		case let value as Int16: return Int(value)
		case let value as UInt16: return Int(value)
		case let value as Int32: return Int(value)
		case let value as UInt32: return Int(value)
		case let value as Int64: return Int(value)
		case let value as UInt64: return Int(value)
		default: assertionFailure("\(type(of: self)) is not compatible")
		}
		return 0
	}
	var unsignedValue: UInt {
		switch self {
		case let value as Int: return UInt(value)
		case let value as UInt: return value
		case let value as Int8: return UInt(value)
		case let value as UInt8: return UInt(value)
		case let value as Int16: return UInt(value)
		case let value as UInt16: return UInt(value)
		case let value as Int32: return UInt(value)
		case let value as UInt32: return UInt(value)
		case let value as Int64: return UInt(value)
		case let value as UInt64: return UInt(value)
		default: assertionFailure("\(type(of: self)) is not compatible")
		}
		return 0
	}
}

