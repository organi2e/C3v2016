//
//  Maschine.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public class Maschine {
	
	internal enum Fehler: Error {
		case KeineImplementierungGefunden
		case BereitsEingesetzt(object: Any)
		case NichtGefunden(funktion: String)
	}
	
	internal typealias Device = MTLDevice
	internal typealias CommandQueue = MTLCommandQueue
	
	internal typealias Library = MTLLibrary
	internal typealias Funktion = MTLFunction
	
	public typealias ComputePipelineState = MTLComputePipelineState
	
	internal let device: Device
	internal let commandQueue: CommandQueue
	
	internal var cache: (
		bundle: Set<Bundle>,
		funktion: [String: Funktion],
		computePipelineState: [String: ComputePipelineState]
	)
	
	public init(device: MTLDevice? = nil) throws {
		guard let device: Device = device ?? MTLCreateSystemDefaultDevice() else {
			throw Fehler.KeineImplementierungGefunden
		}
		self.device = device
		self.commandQueue = device.makeCommandQueue()
		
		self.cache.funktion = [:]
		self.cache.computePipelineState = [:]
		self.cache.bundle = []
	}
	private func employ(library: Library) throws {
		try library.functionNames.forEach {
			if let funktion: Funktion = library.makeFunction(name: $0) {
				if cache.funktion.index(forKey: $0) == nil {
					cache.funktion[$0] = funktion
				} else {
					throw Fehler.BereitsEingesetzt(object: $0)
				}
			} else {
				throw Fehler.NichtGefunden(funktion: $0)
			}
		}
	}
	public func employ(bundle: Bundle) throws {
		if cache.bundle.contains(bundle) {
			throw Fehler.BereitsEingesetzt(object: bundle)
		}
		try employ(library: try device.makeDefaultLibrary(bundle: bundle))
		cache.bundle.insert(bundle)
	}
}
