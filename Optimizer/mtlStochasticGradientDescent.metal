//
//  mtlStochasticGradientDescent.metal
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void StochasticGradientDescent(device float4 * const value [[ buffer(0) ]],
									  device const float4 * const delta [[ buffer(1) ]],
									  constant float & eta [[ buffer(2) ]],
									  uint const n [[ thread_position_in_grid ]]
									  ) {
	value [ n ] -= eta * delta [ n ];
}
