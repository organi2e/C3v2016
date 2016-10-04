//
//  BrassTests.swift
//  C³
//
//  Created by Kota on 10/4/16.
//
//

import XCTest
import LaObjet
import Maschine
import Brass


class BrassTests: XCTestCase {
	
	let maschine: Maschine = try!Maschine()
	
	func testGEMM() {
		do {
			let maschine: Maschine = try Maschine()
			let brass: Brass<Float> = try Brass(maschine: maschine)
			let P: Int = 1
			let M: Int = 16
			let K: Int = 16
			let N: Int = 16
			let y: Buffer<Float> = maschine.newBuffer(count: M*N)
			let a: Buffer<Float> = maschine.newBuffer(count: M*K)
			let b: Buffer<Float> = maschine.newBuffer(count: K*N)
			
			(0..<M*K).forEach {
				a[$0] = Float(drand48())
			}
			(0..<K*N).forEach {
				b[$0] = Float(drand48())
			}
			
			let commandBuffer: CommandBuffer = maschine.newCommandBuffer()
			brass.gemm(commandBuffer: commandBuffer, y, a, b, m: M, k: K, n: N)
			commandBuffer.commit()
			commandBuffer.waitUntilCompleted()
			print(y.array)
			
			let A: LaObjet<Float> = LaObjet(valuer: a.address, rows: M, cols: K, deallocator: nil)
			let B: LaObjet<Float> = LaObjet(valuer: b.address, rows: K, cols: N, deallocator: nil)
			print(matrix_product(A, B).array)
			
			
			/*
			if false {
				measure {
					let commandBuffer: CommandBuffer = maschine.newCommandBuffer()
					for _ in 0..<P {
						brass.gemm(commandBuffer: commandBuffer, y, a, x, m: M, k: K, n: N)
					}
					commandBuffer.commit()
					commandBuffer.waitUntilCompleted()
				}
			} else {
				measure {
					for _ in 0..<P {
						let A: LaObjet<Float> = LaObjet(valuer: a.address, rows: M, cols: K, deallocator: nil)
						let X: LaObjet<Float> = LaObjet(valuer: x.address, rows: K, cols: N, deallocator: nil)
						matrix_product(A, X).copy(to: y.address)
					}
				}
			}
			*/
			
		} catch {
			XCTFail(String(describing: error))
		}
	}
	/*
	func testGEMV() {
		do {
			let brass: Brass<Float> = try Brass(maschine: maschine)
			let P: Int = 1
			let M: Int = 32
			let N: Int = 32
			let y: Buffer<Float> = maschine.newBuffer(count: M)
			let a: Buffer<Float> = maschine.newBuffer(count: M*N)
			let x: Buffer<Float> = maschine.newBuffer(count: N)
			for n in 0..<N {
				x[n] = Float(n)
				for m in 0..<M {
					a[m*N+n] = Float(m)
				}
			}
			
			measure {
				let commandBuffer: CommandBuffer = self.maschine.newCommandBuffer()
				for _ in 0..<P {
					brass.gemv(commandBuffer: commandBuffer, y, a, x, m: M, n: N)
				}
				commandBuffer.commit()
				commandBuffer.waitUntilCompleted()
				/*
				for p in 0..<P {
					let A: LaObjet<Float> = LaObjet(valuer: a.address, rows: M, cols: N, deallocator: nil)
					let X: LaObjet<Float> = LaObjet(valuer: x.address, rows: N, cols: 1, deallocator: nil)
					matrix_product(A, X).copy(to: y.address)
				}
				*/
			}
			print(y.array)
			
			let A: LaObjet<Float> = LaObjet(valuer: a.address, rows: M, cols: N, deallocator: nil)
			let X: LaObjet<Float> = LaObjet(valuer: x.address, rows: N, cols: 1, deallocator: nil)
			print(matrix_product(A, X).array)
			
		} catch {
			print(error)
			XCTFail()
		}
		
	}
	*/
}
