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
	typealias T = Double
	let M: Int = 4
	let N: Int = 4
	private func uniform() -> [T] {
		return(0..<N*M).map{(_)in T(arc4random())/sqrt(T(UInt32.max))}
	}
	
	func testAddVV() {
		let a = uniform()
		let b = uniform()
		let c = zip(a,b).map(+)
		let A = LaObjet<T>(valuer: a, rows: a.count, cols: 1, deallocator: nil)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A+B).array.elementsEqual(c))
	}
	
	func testSubVV() {
		let a = uniform()
		let b = uniform()
		let c = zip(a,b).map(-)
		let A = LaObjet<T>(valuer: a, rows: a.count, cols: 1, deallocator: nil)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A-B).array.elementsEqual(c))
	}
	
	func testMulVV() {
		let a = uniform()
		let b = uniform()
		let c = zip(a,b).map(*)
		let A = LaObjet<T>(valuer: a, rows: a.count, cols: 1, deallocator: nil)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A*B).array.elementsEqual(c))
	}
	
	func testDivVV() {
		let a = uniform()
		let b = uniform()
		let c = zip(a,b).map(/)
		let A = LaObjet<T>(valuer: a, rows: a.count, cols: 1, deallocator: nil)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		if 1e-5 < ((A/B)-LaObjet<T>(valuer: c, rows: c.count, cols: 1)).L2Norme {
			XCTFail()
			print((A/B).array)
			print(c)
		}
	}
	
	func testAddSV() {
		let a = uniform()[0]
		let b = uniform()
		let c = b.map { a + $0 }
		let A = LaObjet<T>(valuer: a)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A+B).array.elementsEqual(c))
	}
	
	func testSubSV() {
		let a = uniform()[0]
		let b = uniform()
		let c = b.map { a - $0 }
		let A = LaObjet<T>(valuer: a)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((A-B).array.elementsEqual(c))
	}
	
	func testSubVS() {
		let a = uniform()[0]
		let b = uniform()
		let c = b.map { $0 - a }
		let A = LaObjet<T>(valuer: a)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		XCTAssert((B-A).array.elementsEqual(c))
	}
	
	func testMulSV() {
		let a = uniform()[0]
		let b = uniform()
		let c = b.map { a * $0 }
		let A = LaObjet<T>(valuer: a)
		let B = LaObjet<T>(valuer: b, rows: M, cols: N, deallocator: nil)
		XCTAssert((A*B).array.elementsEqual(c))
	}
	
	func testDivSV() {
		let a = uniform()[0]
		let b = uniform()
		let c = b.map { a / $0 }
		let A = LaObjet<T>(valuer: a)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		if 1e-5 < ((A/B) - LaObjet<T>(valuer: c, rows: b.count, cols: 1, deallocator: nil)).LINFNorme {
			XCTFail()
			print((A/B).array)
			print(c)
		}
	}
	
	func testDivVS() {
		let a = uniform()[0]
		let b = uniform()
		let c = b.map { $0 / a }
		let A = LaObjet<T>(valuer: a)
		let B = LaObjet<T>(valuer: b, rows: b.count, cols: 1, deallocator: nil)
		if 1e-5 < ((B/A) - LaObjet<T>(valuer: c, rows: b.count, cols: 1, deallocator: nil)).LINFNorme {
			XCTFail()
			print((B/A).array)
			print(c)
		}
	}
}
