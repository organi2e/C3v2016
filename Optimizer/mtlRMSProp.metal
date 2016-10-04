//
//  C³.metal
//  C³
//
//  Created by Kota on 10/4/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void RMSProp(device float4 * const value [[ buffer(0) ]],
					device const float4 * const nabla [[ buffer(1) ]],
					device const float4 * const delta [[ buffer(2) ]],
					device float4 * const r [[ buffer(3) ]],
					constant float & alpha [[ buffer(4) ]],
					constant float & gamma [[ buffer(5) ]],
					constant float & epsilon [[ buffer(6) ]],
					uint const n [[ thread_position_in_grid ]]
					) {
	float4 accelerate = nabla [ n ] * delta [ n ];
	r [ n ] = gamma * r [ n ] + ( 1 - gamma ) * accelerate * accelerate;
	value [ n ] -= alpha * accelerate * rsqrt( r [ n ] + epsilon );
}
