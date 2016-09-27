//
//  MaschineTests.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import XCTest
import Maschine

class MaschineTests: XCTestCase {

	func testAdd() {
		do {
			
			let maschine: Maschine = try Maschine()
			
			try maschine.entry(bundle: Bundle(for: type(of: self)))
			
			let a: Buffer<Float> = maschine.newBuffer(count: 8)
			let b: Buffer<Float> = maschine.newBuffer(count: 8)
			let c: Buffer<Float> = maschine.newBuffer(count: 8)
			
			for k in 0 ..< 8 {
				a[k] = Float(k)
				b[k] = Float(k*k)
			}
			
			let add = try maschine.newComputePipelineState(name: "add")
			let command: Command = maschine.newCommand()
			command.compute {
				$0.set(pipeline: add)
				$0.set(buffer: a, offset: 0, at: 1)
				$0.set(buffer: b, offset: 0, at: 2)
				$0.set(buffer: c, offset: 0, at: 0)
				$0.dispatch(groups: 8, threads: 1)
			}
			command.commit()
			command.waitUntilCompleted()
			
			print(c.array)
			
		} catch {
			XCTFail()
		}
	}
	
}
