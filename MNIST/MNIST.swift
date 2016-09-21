//
//  MNIST.swift
//  OSX
//
//  Created by Kota Nakano on 5/23/16.
//
//
import Foundation
public class MNIST {
	public struct Image {
		public let rows: Int
		public let cols: Int
		public let label: UInt8
		public let pixel: [UInt8]
		public var bgra: [UInt8] {
			return ( 0 ..< rows * cols ) .map { [pixel[$0], pixel[$0], pixel[$0], 255] } .reduce ( [] ) { $0.0 + $0.1 }
		}
		public var meta: String {
			return String(label)
		}
		//I hate fileprivate
		internal init(pixel: [UInt8], label: UInt8, rows: Int, cols: Int) {
			self.label = label
			self.pixel = pixel
			self.rows = rows
			self.cols = cols
		}
	}
	private static func load(image: String, label: String) -> [Image] {
		func dataFromBundle(path: String) -> Data? {
			guard let url: URL = Bundle(for: MNIST.self).url(forResource: path, withExtension: nil) else { return nil }
			do {
				return try Data(contentsOf: url)
			} catch {
				return nil
			}
		}
		if let data: Data = dataFromBundle(path: image), MemoryLayout<UInt32>.size * 4 < data.count {
			
			let(headdata, bodydata) = data.split(cursor: MemoryLayout<UInt32>.size * 4)
			let head: [UInt32] = headdata.toArray().map{ UInt32(bigEndian: $0) }
			let length: Int = Int(head[1])
			let rows: Int = Int(head[2])
			let cols: Int = Int(head[3])
			let pixelsbody: [UInt8] = bodydata.toArray()
			if length * rows * cols == pixelsbody.count, let data: Data = dataFromBundle(path: label), MemoryLayout<UInt32>.size * 2 < data.count {
				let(headdata, bodydata) = data.split(cursor: MemoryLayout<UInt32>.size * 2)
				let head: [UInt32] = headdata.toArray() .map { UInt32(bigEndian: $0) }
				let length: UInt32 = head[1]
				let labelsbody: [UInt8] = bodydata.toArray()
				if length == UInt32(labelsbody.count) {
					let pixels: [[UInt8]] = pixelsbody.chunk(width: rows*cols)
					let labels: [UInt8] = labelsbody
					return zip(pixels, labels).map { Image(pixel: $0, label: $1, rows: rows, cols: cols) }
				}
			}
		}
		return []
	}
	public static let train: [Image] = MNIST.load(image: "train-images-idx3-ubyte", label: "train-labels-idx1-ubyte")
	public static let t10k: [Image] = MNIST.load(image: "t10k-images-idx3-ubyte", label: "t10k-labels-idx1-ubyte")
}
extension Data {
	func split(cursor: Int) -> (Data, Data){
		return(
			subdata(in: 0..<startIndex.advanced(by: cursor)),
			subdata(in: startIndex.advanced(by: cursor)..<endIndex)
		)
	}
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
