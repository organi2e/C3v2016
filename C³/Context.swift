//
//  Context.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//
import CoreData
public class Context: NSManagedObjectContext {
	struct MTL {
		let device: MTLDevice
		let queue: MTLCommandQueue
		init(device: MTLDevice) {
			self.device = device
			self.queue = device.makeCommandQueue()
		}
	}
	private let mtl: MTL
	init() {
		mtl = MTL(device: MTLCreateSystemDefaultDevice()!)
		super.init(concurrencyType: .privateQueueConcurrencyType)
	}
	public required init?(coder aDecoder: NSCoder) {
		mtl = MTL(device: MTLCreateSystemDefaultDevice()!)
		super.init(coder: aDecoder)
	}
}
