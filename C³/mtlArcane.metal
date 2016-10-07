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
						  device float4 * const gradmu [[ buffer(2) ]],
						  device float4 * const gradsigma [[ buffer(3) ]],
						  device const float4 * const argmu [[ buffer(4) ]],
						  device const float4 * const argsigma [[ buffer(5) ]],
						  uint const n [[ thread_position_in_grid ]],
						  uint const N [[ threads_per_grid ]]) {
	{
		mu [ n ] = argmu [ n ];
		gradmu [ n ] = 1;
	}
	{
		float4 const p = 1 + exp ( argsigma [ n ] );
		sigma [ n ] = log ( p );
		gradsigma [ n ] = 1 - 1 / p;
	}
}
