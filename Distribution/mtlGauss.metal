//
//  mtlGauss.metal
//  C³
//
//  Created by Kota Nakano on 9/26/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void gaussPDF(device float4 * const pdf [[ buffer(0) ]],
					 device const float4 * const value [[ buffer(1) ]],
					 device const float4 * const mu [[ buffer(2) ]],
					 device const float4 * const sigma [[ buffer(3) ]],
					 uint const n [[ thread_position_in_grid ]],
					 uint const N [[ threads_per_grid ]]
					 ) {
	
}

kernel void gaussCDF(device float4 * const pdf [[ buffer(0) ]],
					 device const float4 * const value [[ buffer(1) ]],
					 device const float4 * const mu [[ buffer(2) ]],
					 device const float4 * const sigma [[ buffer(3) ]],
					 uint const n [[ thread_position_in_grid ]],
					 uint const N [[ threads_per_grid ]]
					 ) {
	
}

kernel void gaussRng(device float4 * const value [[ buffer(0) ]],
					 device const float4 * const mu [[ buffer(1) ]],
					 device const float4 * const sigma [[ buffer(2) ]],
					 device const uint4 * const seeds [[ buffer(3) ]],
					 constant uint4 & param [[ buffer(4) ]],
					 uint const n [[ thread_position_in_grid ]],
					 uint const N [[ threads_per_grid ]]
					 ) {
	
	uint const a = param.x;
	uint const b = param.y;
	uint const c = param.z;
	uint const K = param.w;
	
	uint4 seq = select ( seeds [ n ], -1, seeds [ n ] == 0 );
	
	for ( uint k = n ; k < K ; k += N ) {
		
		float4 const u = ( float4 ( seq ) + 1 ) / 4294967296.0;
		float2 const xy = 2.0 * u.xy;
		float2 const zw = u.zw;
		
		value [ k ] = mu [ k ] + sigma [ k ] * float4( fast :: cospi( xy ), fast :: sinpi( xy ) ) * fast :: sqrt( -2 * fast :: log( zw ).xyxy );
		
		seq ^= seq >> a;
		seq ^= seq << b;
		seq ^= seq >> c;
		
	}
}

kernel void gaussGrn(device float4 * const gradmu [[ buffer(0) ]],
					 device float4 * const gradlambda [[ buffer(1) ]],
					 device const float4 * const mu [[ buffer(2) ]],
					 device const float4 * const lambda [[ buffer(3) ]],
					 constant float & M_SQRT1_2PI [[ buffer(4) ]],
					 uint const n [[ thread_position_in_grid ]],
					 uint const N [[ threads_per_grid ]]) {
	float4 const m = mu [ n ];
	float4 const l = lambda [ n ];
	float4 const x = m * l;
	float4 const g = M_SQRT1_2PI * exp ( -0.5 * x * x );
	gradmu [ n ] = g * l;
	gradlambda [ n ] = g * m;
}
