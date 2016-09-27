//
//  Maschine.swift
//  C³
//
//  Created by Kota Nakano on 9/27/16.
//
//

import Metal

public class Maschine {
	
	enum Fehler: Error {
		case KeineImplementierungGefunden
		case FunktionNichtGefunden(name: String)
	}
	
	internal typealias Device = MTLDevice
	internal typealias CommandQueue = MTLCommandQueue
	
	internal typealias Library = MTLLibrary
	internal typealias Funktion = MTLFunction
	
	public typealias ComputePipelineState = MTLComputePipelineState
	
	internal let device: Device
	internal let commandQueue: CommandQueue
	
	private var cache: (
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
		
	}
	public func newComputePipelineState(name: String) throws -> ComputePipelineState {
		guard let funktion: Funktion = cache.funktion[name] else {
			throw Fehler.FunktionNichtGefunden(name: name)
		}
		return try device.makeComputePipelineState(function: funktion)
	}
	private func entry(library: Library) throws {
		try library.functionNames.forEach {
			if let funktion: Funktion = library.makeFunction(name: $0) {
				if cache.funktion.index(forKey: $0) == nil {
					cache.funktion[$0] = funktion
				} else {
					//nop throw Fehler.FunktionNichtGefunden(name: $0)
				}
			} else {
				throw Fehler.FunktionNichtGefunden(name: $0)
			}
		}
	}
	public func entry(bundle: Bundle) throws {
		try entry(library: try device.makeDefaultLibrary(bundle: bundle))
	}
}
