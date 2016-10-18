//
//  mtlArcane.metal
//  C³
//
//  Created by Kota on 10/3/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void arcaneRefresh(device float4 * const mu [[ buffer(0) ]],
						  device float4 * const sigma [[ buffer(1) ]],
						  device float4 * const deltamu [[ buffer(2) ]],
						  device float4 * const deltasigma [[ buffer(3) ]],
						  device const float4 * const lambdamu [[ buffer(4) ]],
						  device const float4 * const lambdasigma [[ buffer(5) ]],
						  uint const n [[ thread_position_in_grid ]],
						  uint const N [[ threads_per_grid ]]) {
	{
		mu [ n ] = lambdamu [ n ];
		deltamu [ n ] = 1;
	}
	{
		float4 const p = 1 + precise :: exp ( lambdasigma [ n ] );
		sigma [ n ] = log ( p );
		deltasigma [ n ] = 1 - 1 / p;
	}
}
