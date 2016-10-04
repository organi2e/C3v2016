//
//  mtlStochasticGradientDescent.metal
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void Momentum(device float4 * const value [[ buffer(0) ]],
					 device const float4 * const nabla [[ buffer(1) ]],
					 device const float4 * const delta [[ buffer(2) ]],
					 device float4 * const velocity [[ buffer(3) ]],
					 constant float & gamma [[ buffer(4) ]],
					 constant float & eta [[ buffer(5) ]],
					 uint const n [[ thread_position_in_grid ]]
					 ) {
	velocity [ n ] = gamma * velocity [ n ] + eta * nabla [ n ] * delta [ n ];
	value [ n ] -= velocity[n];
}
