//
//  CIFAR10.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//

import Foundation
public class CIFAR10 {
	public struct Image {
		public let label: UInt8
		public let r: [UInt8]
		public let g: [UInt8]
		public let b: [UInt8]
		public var bgra: [UInt8] {
			let count: Int = rows * cols
			assert(r.count==count)
			assert(g.count==count)
			assert(b.count==count)
			return(0..<count).map { [b[$0], g[$0], r[$0], 255] }.reduce([]) { $0.0 + $0.1 }
		}
		public var meta: String {
			let index: Int = Int(label)
			return index < CIFAR10.meta.count ? CIFAR10.meta[index] : ""
		}
		public var cols: Int {
			return CIFAR10.cols
		}
		public var rows: Int {
			return CIFAR10.rows
		}
		fileprivate init(label: UInt8, r: [UInt8], g: [UInt8], b: [UInt8]) {
			self.label = label
			self.r = r
			self.g = g
			self.b = b
		}
	}
	private static let rows: Int = 32
	private static let cols: Int = 32
	private static var bundle: Bundle {
		return Bundle(for: CIFAR10.self)
	}
	private static func batch(path: String, ext: String = "bin") -> [Image] {
		if let url: URL = bundle.url(forResource: path, withExtension: ext), let data: Data = try?Data(contentsOf: url) {
			let count: Int = rows * cols
			let data: [UInt8] = data.toArray()
			assert( data.count % (1+3*count) == 0 )
			return data.chunk(width: 1+3*count).map {
				let label: UInt8 = $0[0]
				let r: [UInt8] = Array<UInt8>($0[1+0*count..<1+1*count])
				let g: [UInt8] = Array<UInt8>($0[1+1*count..<1+2*count])
				let b: [UInt8] = Array<UInt8>($0[1+2*count..<1+3*count])
				return Image(label: label, r: r, g: g, b: b)
			}
		}
		return []
	}
	private static func meta(path: String, ext: String = "txt") -> [String] {
		if let url: URL = bundle.url(forResource: path, withExtension: ext), let text: String = try?String(contentsOf: url) {
			return text.components(separatedBy: "\n")
		}
		return []
	}
	public static let batch1: [Image] = CIFAR10.batch(path: "data_batch_1")
	public static let batch2: [Image] = CIFAR10.batch(path: "data_batch_2")
	public static let batch3: [Image] = CIFAR10.batch(path: "data_batch_3")
	public static let batch4: [Image] = CIFAR10.batch(path: "data_batch_4")
	public static let batch5: [Image] = CIFAR10.batch(path: "data_batch_5")
	public static let test: [Image] = CIFAR10.batch(path: "test_batch")
	public static let meta: [String] = CIFAR10.meta(path: "batches.meta")
}
extension Data {
	func toArray<T>() -> [T] {
		let result: UnsafeMutableBufferPointer<T> = UnsafeMutableBufferPointer<T>(start: UnsafeMutablePointer<T>.allocate(capacity: count), count: count/MemoryLayout<T>.size)
		defer { result.baseAddress?.deallocate(capacity: result.count*MemoryLayout<T>.size) }
		assert(copyBytes(to: result)==count)
		return Array<T>(result)
	}
}
extension Array {
	func chunk(width: Int) -> [[Element]] {
		return stride(from: 0, to: count, by: width).map{Array(self[$0..<$0.advanced(by: width)])}
	}
}
