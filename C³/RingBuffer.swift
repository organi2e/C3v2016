//
//  RingBuffer.swift
//  C³
//
//  Created by Kota on 10/3/16.
//
//

import Foundation

internal struct RingBuffer<T> {
	private var cursor: Int
	private var buffer: Array<T>
	mutating func progress() {
		cursor = ( cursor + 1 ) % length
	}
	init(array: Array<T>) {
		cursor = 0
		buffer = array
	}
	var curr: T {
		return buffer[(cursor+length-0)%length]
	}
	var prev: T {
		return buffer[(cursor+length-1)%length]
	}
	subscript(index: Int) -> T {
		return buffer[index%buffer.count]
	}
	var length: Int {
		return buffer.count
	}
}
