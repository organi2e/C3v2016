//
//  LaObjetTest.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//
import Accelerate
import XCTest
//@testable
import LaObjet
class LaObjetTests: XCTestCase {
	let M: Int = 4
	let N: Int = 4
	private func uniform() -> [Float] {
		return(0..<N*M).map{(_)in Float(arc4random())/sqrt(Float(UInt32.max))}
	}
	private func uniform() -> Float {
		return Float(arc4random())/Float(UInt32.max)
	}
	func testAddVV() {
		let a: [Float] = uniform()
		let b: [Float] = uniform()
		let c: [Float] = zip(a,b).map { $0.0 + $0.1 }
		let A: LaObjet = LaMatrice(valuer: a, rows: a.count, cols: 1, deallocator: nil)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A+B).eval.elementsEqual(c))
	}
	
	func testSubVV() {
		let a: [Float] = uniform()
		let b: [Float] = uniform()
		let c: [Float] = zip(a,b).map { $0.0 - $0.1 }
		let A: LaObjet = LaMatrice(valuer: a, rows: a.count, cols: 1, deallocator: nil)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A-B).eval.elementsEqual(c))
	}
	
	func testMulVV() {
		let a: [Float] = uniform()
		let b: [Float] = uniform()
		let c: [Float] = zip(a,b).map { $0.0 * $0.1 }
		let A: LaObjet = LaMatrice(valuer: a, rows: a.count, cols: 1, deallocator: nil)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A*B).eval.elementsEqual(c))
	}
	
	func testDivVV() {
		let a: [Float] = uniform()
		let b: [Float] = uniform()
		let c: [Float] = zip(a,b).map { $0.0 / $0.1 }
		let A: LaObjet = LaMatrice(valuer: a, rows: a.count, cols: 1, deallocator: nil)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		if 1e-5 < ((A/B)-LaMatrice(valuer: c, rows: c.count, cols: 1)).L2Norme {
			XCTFail()
			print((A/B).eval)
			print(c)
		}
	}
	
	func testAddSV() {
		let a: Float = uniform()
		let b: [Float] = uniform()
		let c: [Float] = b.map { a + $0 }
		let A: LaObjet = LaMatrice(valuer: a)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A+B).eval.elementsEqual(c))
	}
	
	func testSubSV() {
		let a: Float = uniform()
		let b: [Float] = uniform()
		let c: [Float] = b.map { a - $0 }
		let A: LaObjet = LaMatrice(valuer: a)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A-B).eval.elementsEqual(c))
	}
	
	func testSubVS() {
		let a: Float = uniform()
		let b: [Float] = uniform()
		let c: [Float] = b.map { $0 - a }
		let A: LaObjet = LaMatrice(valuer: a)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((B-A).eval.elementsEqual(c))
	}
	
	func testMulSV() {
		let a: Float = uniform()
		let b: [Float] = uniform()
		let c: [Float] = b.map { a * $0 }
		let A: LaObjet = LaMatrice(valuer: a)
		let B: LaObjet = LaMatrice(valuer: b, rows: M, cols: N, deallocator: nil)
		XCTAssert((A*B).eval.elementsEqual(c))
	}
	
	func testDivSV() {
		let a: Float = uniform()
		let b: [Float] = uniform()
		let c: [Float] = b.map { a / $0 }
		let A: LaObjet = LaMatrice(valuer: a)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		if 1e-5 < ((A/B) - LaMatrice(valuer: c, rows: b.count, cols: 1, deallocator: nil)).L2Norme {
			XCTFail()
			print((A/B).eval)
			print(c)
		}
	}
	
	func testDivVS() {
		let a: Float = uniform()
		let b: [Float] = uniform()
		let c: [Float] = b.map { $0 / a }
		let A: LaObjet = LaMatrice(valuer: a)
		let B: LaObjet = LaMatrice(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		if 1e-3 < ((B/A) - LaMatrice(valuer: c, rows: b.count, cols: 1, deallocator: nil)).L2Norme {
			XCTFail()
			print((B/A).eval)
			print(c)
		}
	}
	
}
