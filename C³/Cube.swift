//
//  Cube.swift
//  C³
//
//  Created by Kota on 10/14/16.
//
//

import Maschine

public class Cube: ManagedObject {
	var state: Buffer<Float>!
	var error: Buffer<Float>!
}
extension Cube {
	@NSManaged var label: String
	@NSManaged var width: UInt
	@NSManaged var height: UInt
	@NSManaged var depth: UInt
	@NSManaged var weight: Data
}
extension Cube {
	override func setup(context: Context) throws {
		state = context.newBuffer(count: Int(width*height*depth)*MemoryLayout<Float>.size)
		error = context.newBuffer(count: Int(width*height*depth)*MemoryLayout<Float>.size)
	}
	func resize(width: UInt, height: UInt, depth: UInt) throws {
		self.width = width
		self.height = height
		self.depth = depth
		weight = Data(count: Int(width*height*depth)*6*MemoryLayout<Float>.size)
		try setup(context: context)
	}
}
extension Context {
	public func newCube(width: UInt, height: UInt, depth: UInt) throws -> Cube {
		guard let cube: Cube = new() else {
			throw EntityError.InsertionError(of: Cube.self)
		}
		cube.label = ""
		try cube.resize(width: width, height: height, depth: depth)
		return cube
	}
}
