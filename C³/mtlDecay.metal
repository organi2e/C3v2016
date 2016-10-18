//
//  mtlDecay.metal
//  C³
//
//  Created by Kota on 10/17/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void decayRefresh(device float4 * const r [[ buffer(0) ]],
						 device float4 * const gradr [[ buffer(1) ]],
						 device const float4 * const lambdar [[ buffer(2) ]],
						 uint const n [[ thread_position_in_grid ]],
						 uint const N [[ threads_per_grid ]]) {
	float4 const t = tanh ( 2 * lambdar [ n ] );
	r [ n ] = 0.5 + 0.5 * t;
	gradr [ n ] = 1 - t * t;
}
