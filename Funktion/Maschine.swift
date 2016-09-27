//
//  Context.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//
import Metal

public typealias Device = MTLDevice

public typealias ComputePipelineState = MTLComputePipelineState
public typealias RenderPipelineState = MTLRenderPipelineState

public enum FunktionError: Error {
	//case KeinFehlerGefunden
	case NichtGefunden(funktion: String)
	case BereitsRegistriert(funktion: String)
}

public class Maschine {
	
	private typealias CommandQueue = MTLCommandQueue
	private let queue: CommandQueue
	
	internal let device: Device
	internal typealias Library = MTLLibrary
	internal typealias Funktion = MTLFunction
	
	internal var cache: (
		funktions: [String: Funktion],
		computePipelines: [String: ComputePipelineState],
		renderPipelines: [String: RenderPipelineState]
	)
	
	public init(device: Device? = nil) throws {
		guard let device: Device = device ?? MTLCreateSystemDefaultDevice() else { fatalError() }
		self.device = device
		self.queue = device.makeCommandQueue()
		self.cache.funktions = [:]
		self.cache.computePipelines = [:]
		self.cache.renderPipelines = [:]
	}
	
	private func bindLibrary(library: Library) throws {
		try library.functionNames.forEach {
			if let funktion: Funktion = library.makeFunction(name: $0) {
				if cache.funktions.index(forKey: $0) != cache.funktions.endIndex {
					cache.funktions.updateValue(funktion, forKey: $0)
				} else {
					throw FunktionError.BereitsRegistriert(funktion: $0)
				}
			} else {
				throw FunktionError.NichtGefunden(funktion: $0)
			}
		}
	}
	
	public func loadLibraryFrom(path: String) throws {
		try bindLibrary(library: try device.makeLibrary(filepath: path))
	}
	
	public func loadLibraryFrom(source: String, fast: Bool = false) throws {
		let options: MTLCompileOptions = MTLCompileOptions()
		options.fastMathEnabled = fast
		try bindLibrary(library: try device.makeLibrary(source: source, options: options))
	}
	
	public func loadLibraryFrom(bundle: Bundle) throws {
		try bindLibrary(library: try device.makeDefaultLibrary(bundle: bundle))
	}

}
