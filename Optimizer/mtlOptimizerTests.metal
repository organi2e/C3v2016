//
//  mtlOptimizerTests.metal
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void loss(device float4 * const nabla [[ buffer(0) ]],
				 device float4 * const delta [[ buffer(1) ]],
				 device const float4 * const value [[ buffer(2) ]],
				 device const float4 * const ans [[ buffer(3) ]],
				 uint const n [[ thread_position_in_grid ]]) {
	delta [ n ] = ( value [ n ] - ans [ n ] ) * ( value [ n ] - ans [ n ] );
	nabla [ n ] = 2 * ( value [ n ] - ans [ n ] );
}
