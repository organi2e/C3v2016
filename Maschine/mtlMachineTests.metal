//
//  mtlMachineTests.metal
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

#include <metal_stdlib>
using namespace metal;

kernel void add(device float * const c [[ buffer(0) ]],
				device const float * const a [[ buffer(1) ]],
				device const float * const b [[ buffer(2) ]],
				uint const n [[ thread_position_in_grid ]]) {
	c[n] = a[n] + b[n];
}
