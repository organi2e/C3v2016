//
//  mtlCauchy.metal
//  C³
//
//  Created by Kota Nakano on 9/26/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void cauchyPDF(device float4 * const pdf [[ buffer(0) ]],
					  device const float4 * const value [[ buffer(1) ]],
					  device const float4 * const mu [[ buffer(2) ]],
					  device const float4 * const sigma [[ buffer(3) ]],
					  uint n [[ thread_position_in_grid ]],
					  uint N [[ threads_per_grid ]]
					  ) {
	
}

kernel void cauchyCDF(device float4 * const pdf [[ buffer(0) ]],
					  device const float4 * const value [[ buffer(1) ]],
					  device const float4 * const mu [[ buffer(2) ]],
					  device const float4 * const sigma [[ buffer(3) ]],
					  uint n [[ thread_position_in_grid ]],
					  uint N [[ threads_per_grid ]]
					  ) {
	
}

kernel void cauchyRng(device float4 * const value [[ buffer(0) ]],
					  device const float4 * const mu [[ buffer(1) ]],
					  device const float4 * const sigma [[ buffer(2) ]],
					  device const float4 * const seeds [[ buffer(3) ]],
					  uint n [[ thread_position_in_grid ]],
					  uint N [[ threads_per_grid ]]
					  ) {
	
}
