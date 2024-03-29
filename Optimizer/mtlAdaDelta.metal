//
//  mtlAdaDelta.metal
//  C³
//
//  Created by Kota on 10/4/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void AdaDelta(device float4 * const value [[ buffer(0) ]],
					 device const float4 * const delta [[ buffer(1) ]],
					 device float4 * const r [[ buffer(2) ]],
					 device float4 * const s [[ buffer(3) ]],
					 constant float & alpha [[ buffer(4) ]],
					 constant float & gamma [[ buffer(5) ]],
					 constant float & epsilon [[ buffer(6) ]],
					 uint const n [[ thread_position_in_grid ]]
					 ) {
	float4 a = delta [ n ];
	r [ n ] = gamma * r [ n ] + ( 1 - gamma ) * a * a;
	float4 v = sqrt ( s [ n ] + epsilon ) * rsqrt ( r [ n ] + epsilon ) * a;
	s [ n ] = gamma * s [ n ] + ( 1 - gamma ) * v * v;
	value [ n ] -= alpha * v;
}


