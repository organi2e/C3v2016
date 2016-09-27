//
//  mtlOptimizerTests.metal
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void loss(device float4 * const dx [[ buffer(0) ]],
				 device const float4 * const x [[ buffer(1) ]],
				 device const float4 * const ans [[ buffer(2) ]],
				 uint const n [[ thread_position_in_grid ]]) {
	float4 deltay = ( x [ n ] - ans [ n ] ) * ( x [ n ] - ans [ n ] );
	float4 dydx = 2 * ( x [ n ] - ans [ n ] );
	dx[n] = deltay * dydx;
}
