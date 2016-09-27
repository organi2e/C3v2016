//
//  OptimizerTests.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import XCTest
import Maschine
import Optimizer

class OptimizerTests: XCTestCase {
	
	let count: Int = 8
	
	var maschine: Maschine!
	var loss: ComputePipelineState!
	var dloss: ComputePipelineState!
	var x: Buffer<Float>!
	var Δx: Buffer<Float>!
	var ans: Buffer<Float>!
	
	override func setUp() {
		super.setUp()
		do {
			maschine = try Maschine()
			x = maschine.newBuffer(count: count)
			Δx = maschine.newBuffer(count: count)
			ans = maschine.newBuffer(count: count)
			(0..<count).forEach {
				x[$0] = Float(drand48())
				ans[$0] = Float($0)
			}
			try maschine.employ(bundle: Bundle(for: type(of: self)))
			loss = try maschine.newComputePipelineState(name: "loss")
		} catch {
			XCTFail()
		}
	}
	
	func loss(command: Command) {
		command.compute {
			$0.set(pipeline: loss)
			$0.set(buffer: Δx, offset: 0, at: 0)
			$0.set(buffer: x, offset: 0, at: 1)
			$0.set(buffer: ans, offset: 0, at: 2)
			$0.dispatch(groups: (count-1)/4+1, threads: 1)
		}
	}
	
	func eval(optimizer: Optimizer) {
		let c: Command = maschine.newCommand()
		for _ in 0..<1024 {
			loss(command: c)
			optimizer.update(command: c, θ: x, Δθ: Δx)
		}
		c.commit()
		c.waitUntilCompleted()
	}
	
	func testSGD() {
		do {
			eval(optimizer: try StochasticGradientDescent(maschine: maschine, count: count, η: 1/96.0))
			print(x.array)
		} catch {
			XCTFail()
		}
	}
	
	func testMomentum() {
		do {
			eval(optimizer: try Momentum(maschine: maschine, count: count, γ: 0.9, η: 1/96.0))
			print(x.array)
		} catch {
			XCTFail()
		}
	}

}
