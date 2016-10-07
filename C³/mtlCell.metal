//
//  mtlCell.metal
//  C³
//
//  Created by Kota on 10/5/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void cellActivate(device float4 * const state [[ buffer(0) ]],
						 device const float4 * const level [[ buffer(1) ]],
						 uint const n [[ thread_position_in_grid ]],
						 uint const N [[ threads_per_grid ]]) {
	state [ n ] = step ( 0.0, level [ n ]);
}
kernel void cellDerivate(device float4 * const delta [[ buffer(0) ]],
						 device const float4 * const error [[ buffer(1) ]],
						 uint const n [[ thread_position_in_grid ]],
						 uint const N [[ threads_per_grid ]]) {
	delta [ n ] = sign ( error [ n ] );
}
