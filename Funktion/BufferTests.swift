//
//  BufferTests.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//

import XCTest
import Funktion
class BufferTests: XCTestCase {

	let maschine: Maschine = try!Maschine()
	
	func testAssign() {
		let x: [Float] = [1, 2, 3]
		
		let a: Buffer = maschine.newBuffer(array: x)
		
		let b: UnsafeMutableBufferPointer<Float> = a.toBuffer()
		b[0] = 5
		
		let y: [Float] = a.toArray()
		
		print(y)
		
		let c = maschine.newCommand()
		c.addCompletedHandler { (_)in
			print("ok")
		}
		c.commit()
		print(2)
		c.waitUntilCompleted()
		print(3)
		
	}

}
