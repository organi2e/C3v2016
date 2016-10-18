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
					 device const float4 * const delta [[ buffer(1) ]],
					 device float4 * const velocity [[ buffer(2) ]],
					 constant float & gamma [[ buffer(3) ]],
					 constant float & eta [[ buffer(4) ]],
					 uint const n [[ thread_position_in_grid ]]
					 ) {
	velocity [ n ] = gamma * velocity [ n ] + eta * delta [ n ];
	value [ n ] -= velocity[n];
}
