//
//  mtlBrass.metal
//  C³
//
//  Created by Kota on 10/4/16.
//
//

#include <metal_stdlib>
using namespace metal;


kernel void sgemm_ss(device float * const y [[ buffer(0) ]],
					 device const float * const a [[ buffer(1) ]],
					 device const float * const b [[ buffer(2) ]],
					 constant uint & M [[ buffer(3) ]],
					 constant uint & K [[ buffer(4) ]],
					 constant uint & N [[ buffer(5) ]],
					 constant uint & L [[ buffer(6) ]],
					 threadgroup float * const A [[ threadgroup(0) ]],
					 threadgroup float * const B [[ threadgroup(1) ]],
					 uint2 const t [[ thread_position_in_threadgroup ]],
					 uint2 const T [[ threads_per_threadgroup ]],
					 uint2 const g [[ threadgroup_position_in_grid ]],
					 uint2 const G [[ threadgroups_per_grid ]]) {
	
	uint const rows_C = g.y * L + t.y;
	uint const cols_C = g.x * L + t.x;
	
	float c = 0;
	
	threadgroup float * const aref = A + L * t.x;
	threadgroup float * const bref = B + L * t.y;
	
	for ( uint i = 0, I = K ; i < I ; i += L ) {
		
		uint const rows_A = i + t.y;
		uint const cols_A = cols_C;
		
		aref[t.y] = rows_A < M && cols_A < K ? a[cols_A*M+rows_A] : 0;
		
		uint const rows_B = rows_C;
		uint const cols_B = i + t.x;
		
		bref[t.x] = rows_B < K && cols_B < N ? b[cols_B*K+rows_B] : 0;
		
		threadgroup_barrier( mem_flags :: mem_threadgroup );
		
		for ( uint k = 0, K = L ; k < K ; ++ k )
			c += aref[k] * bref[k];
		
		threadgroup_barrier( mem_flags :: mem_threadgroup );
	}
	if ( rows_C < M && cols_C < N ) {
		uint const idx = cols_C * M + rows_C;
		y[idx] = c;
	}
}

kernel void sgemv_n(device float4 * const y [[ buffer(0) ]],
					device const float * const a [[ buffer(1) ]],
					device const float4 * const x [[ buffer(2) ]],
					constant uint & M [[ buffer(3) ]],
					constant uint & N [[ buffer(4) ]],
					threadgroup float4 * accumulator [[ threadgroup(0) ]],
					uint const t [[ thread_position_in_threadgroup ]],
					uint const T [[ threads_per_threadgroup ]],
					uint const g [[ threadgroup_position_in_grid ]],
					uint const G [[ threadgroups_per_grid ]]) {
	float4 sum = 0;
	for ( uint k = t, K = ( N - 1 ) / 4 + 1 ; k < K ; k += T ) {
		uint4 const cols = 4 * k + uint4(0, 1, 2, 3);
		uint4 const rows = 4 * g * N + uint4(0, 1, 2, 3);
		uint4 const row0 = 4 * g * N + cols;
		uint4 const row1 = row0 + N;
		uint4 const row2 = row1 + N;
		uint4 const row3 = row2 + N;
		float4x4 const A = float4x4(
									float4((rows[0]<M&&cols[0]<N)?a[row0.x]:0, (rows[0]<M&&cols[1]<N)?a[row0.y]:0, (rows[0]<M&&cols[2]<N)?a[row0.z]:0, (rows[0]<M&&cols[3]<N)?a[row0.w]:0),
									float4(a[row1.x], a[row1.y], a[row1.z], a[row1.w]),
									float4(a[row2.x], a[row2.y], a[row2.z], a[row2.w]),
									float4(a[row3.x], a[row3.y], a[row3.z], a[row3.w])
		);
		sum += x [ k ] * A;
	}
	accumulator [ t ] = sum;
	uint offset = T;
	while ( offset >>= 1 ) {
		threadgroup_barrier(mem_flags::mem_threadgroup);
		if ( t < offset ) {
			accumulator [ t ] += accumulator [ t + offset ];
		}
	}
	if ( !t ) {
		y [ g ] = accumulator[0];
	}
}
