//
//  mtlOptimizerTests.metal
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void loss(device float4 * const delta [[ buffer(0) ]],
				 device const float4 * const value [[ buffer(1) ]],
				 device const float4 * const ans [[ buffer(2) ]],
				 uint const n [[ thread_position_in_grid ]]) {
	float4 E = ( value [ n ] - ans [ n ] ) * ( value [ n ] - ans [ n ] );
	float4 G = 2 * ( value [ n ] - ans [ n ] );
	delta [ n ] = E * G;
}
