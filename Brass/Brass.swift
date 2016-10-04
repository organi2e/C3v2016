//
//  Brass.swift
//  C³
//
//  Created by Kota on 10/4/16.
//
//

import Maschine

private class package {

}

public class Brass<T: FloatingPoint> {
	let gemm_ss: ComputePipelineState
	let gemv_n: ComputePipelineState
	let bs: Int = 16
	public init(maschine: Maschine) throws {
		try maschine.employ(bundle: Bundle(for: package.self))
		gemm_ss = try maschine.newComputePipelineState(name: "sgemm_ss")
		gemv_n = try maschine.newComputePipelineState(name: "sgemv_n")
	}
	public func gemm(commandBuffer: CommandBuffer, _ y: Buffer<T>, _ a: Buffer<T>, _ b: Buffer<T>, m: Int, k: Int, n: Int, t: (Bool, Bool) = (false, false)) {
		let l: Int = 4
		commandBuffer.compute {
			switch t {
			case (false, false):
				$0.set(pipeline: gemm_ss)
			case (false, true):
				$0.set(pipeline: gemm_ss)
			case (true, false):
				$0.set(pipeline: gemm_ss)
			case (true, true):
				$0.set(pipeline: gemm_ss)
			}
			$0.set(buffer: y, offset: 0, at: 0)
			$0.set(buffer: a, offset: 0, at: 1)
			$0.set(buffer: b, offset: 0, at: 2)
			$0.set(value: uint(m), at: 3)
			$0.set(value: uint(k), at: 4)
			$0.set(value: uint(n), at: 5)
			$0.set(value: uint(l), at: 6)
			$0.set(sharedBytes: MemoryLayout<Float>.size*l*l, at: 0)
			$0.set(sharedBytes: MemoryLayout<Float>.size*l*l, at: 1)
			$0.dispatch(groups: (width: m/l, height: n/l), threads: (width: l, height: l))
		}
	}
	public func gemv(commandBuffer: CommandBuffer, _ y: Buffer<T>, _ a: Buffer<T>, _ x: Buffer<T>, m: Int, n: Int, t: Bool = false) {
		commandBuffer.compute {
			$0.set(pipeline: gemv_n)
			$0.set(buffer: y, offset: 0, at: 0)
			$0.set(buffer: a, offset: 0, at: 1)
			$0.set(buffer: x, offset: 0, at: 2)
			$0.set(value: uint(m), at: 3)
			$0.set(value: uint(n), at: 4)
			$0.set(sharedBytes: MemoryLayout<Float>.size*4*bs, at: 0)
			$0.dispatch(groups: (m-1)/4+1, threads: bs)
		}
	}
}
