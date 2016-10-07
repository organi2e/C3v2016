//
//  Buffer.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public class Buffer<T> {
	
	internal let body: MTLBuffer
	
	internal init(body: MTLBuffer) {
		self.body = body
	}
	public var pointer: UnsafeMutableRawPointer {
		return body.contents()
	}
	public var address: UnsafeMutablePointer<T> {
		return UnsafeMutablePointer<T>(OpaquePointer(body.contents()))
	}
	public var buffer: UnsafeMutableBufferPointer<T> {
		return UnsafeMutableBufferPointer<T>(start: UnsafeMutablePointer<T>(OpaquePointer(body.contents())), count: body.length/MemoryLayout<T>.size)
	}
	public var array: Array<T> {
		return Array<T>(UnsafeMutableBufferPointer<T>(start: UnsafeMutablePointer<T>(OpaquePointer(body.contents())), count: body.length/MemoryLayout<T>.size))
	}
	public var length: Int {
		return body.length
	}
	public var count: Int {
		return body.length/MemoryLayout<T>.size
	}
	public var data: Data {
		return Data(bytesNoCopy: body.contents(), count: body.length, deallocator: .none)
	}
	public subscript(index: Int) -> T {
		get {
			assert(0<=index&&index<count)
			return UnsafeMutablePointer<T>(OpaquePointer(body.contents()))[index]
		}
		set {
			assert(0<=index&&index<count)
			UnsafeMutablePointer<T>(OpaquePointer(body.contents()))[index] = newValue
		}
	}
	public func didChange(location: Int? = nil, length: Int? = nil) {
		let loc: Int = location ?? 0
		let len: Int = length ?? body.length - loc
		body.didModifyRange(NSRange(location: loc, length: len))
	}
}

extension Maschine {
	public typealias ResourceOptions = MTLResourceOptions
	public func newBuffer<T>(count: Int, options: ResourceOptions = .storageModeShared) -> Buffer<T> {
		return Buffer<T>(body: device.makeBuffer(length: MemoryLayout<T>.size*count, options: options))
	}
	public func newBuffer<T>(array: Array<T>, options: ResourceOptions = .storageModeShared) -> Buffer<T> {
		return Buffer<T>(body: device.makeBuffer(bytes: UnsafePointer<T>(array), length: MemoryLayout<T>.size*array.count, options: options))
	}
	public func newBuffer<T>(array: Array<T>, options: ResourceOptions = .storageModeShared, deallocator: ((UnsafeMutableRawPointer, Int)->Void)?) -> Buffer<T> {
		return Buffer<T>(body: device.makeBuffer(bytesNoCopy: UnsafeMutablePointer<T>(mutating: array), length: MemoryLayout<T>.size*array.count, options: options, deallocator: deallocator))
	}
	public func newBuffer<T>(data: Data, options: ResourceOptions = .storageModeShared) -> Buffer<T> {
		return Buffer<T>(body: device.makeBuffer(bytes: (data as NSData).bytes, length: data.count, options: options))
	}
	public func newBuffer<T>(data: Data, options: ResourceOptions = .storageModeShared, deallocator: ((UnsafeMutableRawPointer, Int)->Void)?) -> Buffer<T> {
		return Buffer<T>(body: device.makeBuffer(bytesNoCopy: UnsafeMutableRawPointer(mutating: (data as NSData).bytes), length: data.count, options: options, deallocator: deallocator))
	}
}
