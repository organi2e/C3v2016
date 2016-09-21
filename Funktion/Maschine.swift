//
//  Context.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//
import Metal

public typealias Device = MTLDevice
typealias Library = MTLLibrary
typealias CommandQueue = MTLCommandQueue
typealias CommandBuffer = MTLCommandBuffer
typealias ComputePipelineState = MTLComputePipelineState
typealias RenderPipelineState = MTLRenderPipelineState

public class Maschine {
	
	typealias Funktion = MTLFunction
	
	let device: Device
	let queue: CommandQueue
	var funktions: [String: Funktion]
	public init(device: Device? = nil) throws {
		guard let device: Device = device ?? MTLCreateSystemDefaultDevice() else {
			fatalError()
		}
		self.device = device
		self.queue = device.makeCommandQueue()
		self.funktions = [:]
		//if let library: Library = device.newDefaultLibrary() {
		//	bindLibrary(library: library)
		//}
	}
	func bindLibrary(library: Library) {
		library.functionNames.forEach {
			if let funktion: Funktion = library.makeFunction(name: $0) {
				funktions.updateValue(funktion, forKey: $0)
			}
		}
	}
	func loadLibraryFrom(path: String) throws {
		bindLibrary(library: try device.makeLibrary(filepath: path))
	}
	func loadLibraryFrom(source: String) throws {
		bindLibrary(library: try device.makeLibrary(source: source, options: nil))
	}
	func loadLibraryFrom(bundle: Bundle) throws {
		//let library: Library = try device.makeDefaultLibrary(bundle: bundle)
	}
	func newCommand() -> Command {
		return queue.makeCommandBuffer()
	}
	func newComputePipeline(funktion: String) throws -> ComputePipelineState {
		guard let funktion: Funktion = funktions[funktion] else {
			fatalError()
		}
		return try device.makeComputePipelineState(function: funktion)
	}
	func newRenderPipeline() throws -> RenderPipelineState {
		typealias RenderPipelineDescriptor = MTLRenderPipelineDescriptor
		let descriptor: RenderPipelineDescriptor = RenderPipelineDescriptor()
		//
		return try device.makeRenderPipelineState(descriptor: descriptor)
	}
}

