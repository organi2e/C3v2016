//
//  GaussianDistributionTests.swift
//  C³
//
//  Created by Kota on 10/4/16.
//
//

import XCTest
import LaObjet
import Maschine
import Distribution

class GaussianDistributionTests: XCTestCase {
	
	
    func testExample() {
		do {
			let N: Int = 1024 * 1024
			
			let maschine: Maschine = try Maschine()
			let distribution: SymmetricStableDistribution = try GaussianDistribution(maschine: maschine)
			
			let r: Buffer<Float> = maschine.newBuffer(count: N)
			let m: Buffer<Float> = maschine.newBuffer(count: N)
			let s: Buffer<Float> = maschine.newBuffer(count: N)
			
			XCTAssert(LaObjet<Float>(valuer: 5, rows: N).copy(to: m.address))
			XCTAssert(LaObjet<Float>(valuer: 8, rows: N).copy(to: s.address))
			
			let commandBuffer: CommandBuffer = maschine.newCommandBuffer()
			distribution.eval(commandBuffer: commandBuffer, χ: r, μ: m, σ: s)
			commandBuffer.commit()
			commandBuffer.waitUntilCompleted()
			
			let(μ, σ) = LaObjet<Float>(valuer: r.address, rows: N, cols: 1, deallocator: nil).statistics
			print(μ, σ)
			
		} catch {
			XCTFail(String(describing: error))
		}
		
		
	}
    
}
