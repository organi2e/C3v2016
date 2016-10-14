//
//  mtlCube.metal
//  C³
//
//  Created by Kota on 10/14/16.
//
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
	float ref[8];
} weight_t;
uint idx(uint,uint,uint,uint,uint,uint);
uint idx(uint x, uint y, uint z, uint X, uint Y, uint Z) {
	return x + X * ( y + Y * ( z ) );
}
uint ref(device const float*const,int,int,int,int,int,int);
uint ref(device const float*const target, int x, int y, int z,int X, int Y, int Z) {
	return 0 < x && x < X - 1 && 0 < y && y < Y - 1 && 0 < z && z < Z - 1 ? target [ x + X * ( y + Y * ( z ) ) ] : 0;
}

kernel void cubeForward(device float * const value [[ buffer(0) ]],
						device const float * const state [[ buffer(2) ]],
						device const weight_t * const weight [[ buffer(4) ]],
						uint3 const n [[ thread_position_in_grid ]],
						uint3 const N [[ threads_per_grid ]]) {
	int const x = n.x, X = N.x;
	int const y = n.y, Y = N.y;
	int const z = n.z, Z = N.z;
	uint const p = idx(x, y, z, X, Y, Z);
	
	value[p] =
		0.5 * value[p] +
		weight[p].ref[2] * state [ idx(x-1, y, z, X, Y, Z) ] +
		weight[p].ref[3] * state [ idx(x+1, y, z, X, Y, Z) ] +
		weight[p].ref[4] * state [ idx(x, y-1, z, X, Y, Z) ] +
		weight[p].ref[5] * state [ idx(x, y+1, z, X, Y, Z) ] +
		weight[p].ref[6] * state [ idx(x, y, z-1, X, Y, Z) ] +
		weight[p].ref[7] * state [ idx(x, y, z+1, X, Y, Z) ];
}
kernel void cubeActivate(device float * const state [[ buffer(0) ]],
						 device const float * const value [[ buffer(2) ]],
						 uint3 const n [[ thread_position_in_grid ]],
						 uint3 const N [[ threads_per_grid ]]) {
	uint const x = n.x, X = N.x;
	uint const y = n.y, Y = N.y;
	uint const z = n.z, Z = N.z;
	uint const p = x + X * ( y + Y * ( z ) );
	state [ p ] = 0.5 + 0.5 * tanh ( 0.5 * value [ p ] );
}
kernel void cubeBackward(device float * const error [[ buffer(0) ]],
						 device const float * const delta [[ buffer(2) ]],
						 device const weight_t * const weight [[ buffer(4) ]],
						 uint3 const n [[ thread_position_in_grid ]],
						 uint3 const N [[ threads_per_grid ]]) {
	int const x = n.x, X = N.x;
	int const y = n.y, Y = N.y;
	int const z = n.z, Z = N.z;
	uint const p = idx(x, y, z, X, Y, Z);
	
	error[p] =
		0.5 * error[p] +
		weight[idx(x+1, y, z, X, Y, Z)].ref[2] * delta[idx(x+1, y, z, X, Y, Z)] +
		weight[idx(x-1, y, z, X, Y, Z)].ref[3] * delta[idx(x-1, y, z, X, Y, Z)] +
		weight[idx(x, y+1, z, X, Y, Z)].ref[4] * delta[idx(x, y+1, z, X, Y, Z)] +
		weight[idx(x, y-1, z, X, Y, Z)].ref[5] * delta[idx(x, y-1, z, X, Y, Z)] +
		weight[idx(x, y, z+1, X, Y, Z)].ref[6] * delta[idx(x, y, z+1, X, Y, Z)] +
		weight[idx(x, y, z-1, X, Y, Z)].ref[7] * delta[idx(x, y, z-1, X, Y, Z)];
}
kernel void cubeDerivate(device float * const delta [[ buffer(0) ]],
						 device const float * const error [[ buffer(1) ]],
						 device const float * const state [[ buffer(2) ]],
						 uint3 const n [[ thread_position_in_grid ]],
						 uint3 const N [[ threads_per_grid ]]) {
	int const x = n.x, X = N.x;
	int const y = n.y, Y = N.y;
	int const z = n.z, Z = N.z;
	uint const p = idx(x, y, z, X, Y, Z);
	delta[p] = error[p] * ( 1 - state[p] * state[p] );
}
kernel void cubeOptimize(device weight_t * const weight [[ buffer(0) ]],
						 device const float * const delta [[ buffer(1) ]],
						 device const float * const state [[ buffer(2) ]],
						 uint3 const n [[ thread_position_in_grid ]],
						 uint3 const N [[ threads_per_grid ]]) {
	
}
