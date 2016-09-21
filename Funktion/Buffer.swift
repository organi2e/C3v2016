//
//  Buffer.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//
import Metal

public typealias Buffer = MTLBuffer

public extension Buffer {
	public typealias Buffer = MTLBuffer
	var data: Data {
		return Data(bytesNoCopy: contents(), count: length, deallocator: .none)
	}
	func toBuffer<T>() -> UnsafeMutableBufferPointer<T> {
		return UnsafeMutableBufferPointer<T>(start: UnsafeMutablePointer<T>(OpaquePointer(contents())), count: length/MemoryLayout<T>.size)
	}
	func toArray<T>() -> Array<T> {
		return Array<T>(UnsafeMutableBufferPointer<T>(start: UnsafeMutablePointer<T>(OpaquePointer(contents())), count: length/MemoryLayout<T>.size))
	}
}

public extension Maschine {
	
	public typealias ResourceOptions = MTLResourceOptions
	
	public func newBuffer(length: Int, options: ResourceOptions = .storageModeShared) -> Buffer {
		return device.makeBuffer(length: length, options: options)
	}
	public func newBuffer(bytes: UnsafeRawPointer, length: Int, options: ResourceOptions = .storageModeShared) -> Buffer {
		return device.makeBuffer(bytes: bytes, length: length, options: options)
	}
	public func newBuffer(data: Data, options: ResourceOptions = .storageModeShared) -> Buffer {
		return device.makeBuffer(bytes: (data as NSData).bytes, length: data.count, options: options)
	}
	public func newBuffer<T>(array: Array<T>, options: ResourceOptions = .storageModeShared) -> Buffer {
		return device.makeBuffer(bytes: UnsafeRawPointer(array), length: MemoryLayout<T>.size*array.count, options: options)
	}
	public func newBuffer<T>(buffer: UnsafeBufferPointer<T>, options: ResourceOptions = .storageModeShared) -> Buffer {
		if let baseAddress: UnsafePointer<T> = buffer.baseAddress {
			return device.makeBuffer(bytes: UnsafeRawPointer(baseAddress), length: MemoryLayout<T>.size*buffer.count, options: options)
		}
		else {
			return device.makeBuffer(length: MemoryLayout<T>.size*buffer.count, options: options)
		}
	}
}
