//
//  Context.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//
import CoreData
import LaObjet
import Maschine
import Optimizer
import Distribution

public class Context: NSManagedObjectContext {
	
	//I hate fileprivate
	internal let maschine: Maschine
	internal let storage: URL?
	internal var optimizer: ((Maschine, Int)throws->Optimizer)
	
	public init(storage: URL?) throws {
		self.maschine = try Maschine(device: MTLCreateSystemDefaultDevice())
		self.storage = storage
		self.optimizer = StochasticGradientDescent.factory(η: 0.5)
		super.init(concurrencyType: .privateQueueConcurrencyType)
		try setup(storage: storage)
	}
	public required init?(coder: NSCoder) {
		self.maschine = try!Maschine(device: MTLCreateSystemDefaultDevice())
		self.storage = coder.decodeObject(forKey: "storage")as?URL
		self.optimizer = StochasticGradientDescent.factory(η: 0.5)
		super.init(coder: coder)
		try!setup(storage: storage)
	}
	public override func encode(with: NSCoder) {
		with.encode(storage, forKey: "storage")
		super.encode(with: with)
	}
	private func setup(storage: URL?) throws {
		guard let model: NSManagedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))]) else { throw SystemError.BrokenBundle }
		let storecoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
		try storecoordinator.addPersistentStore(ofType: storage?.pathExtension == "sqlite" ? NSSQLiteStoreType : storage != nil ? NSBinaryStoreType : NSInMemoryStoreType, configurationName: nil, at: storage, options: nil)
		persistentStoreCoordinator = storecoordinator
		
		try maschine.employ(bundle: Bundle(for: type(of: self)))
	}
}
extension Context {
	enum SystemError: String, Error {
		case InvalidContext = "Context may not correct"
		case BrokenBundle = "Framework Bundle is Broken"
	}
	enum EntityError: Error {
		case InsertionError(of: ManagedObject.Type)
	}
}
extension Context {
	internal func newBuffer<T>(count: Int, options: MTLResourceOptions = .storageModeShared) -> Buffer<T> {
		return maschine.newBuffer(count: count, options: options)
	}
	internal func newBuffer<T>(data: Data, options: MTLResourceOptions = .storageModeShared) -> Buffer<T> {
		return maschine.newBuffer(data: data, options: options)
	}
	internal func newCommandBuffer() -> CommandBuffer {
		return maschine.newCommandBuffer()
	}
	internal func newComputePipelineState(name: String) throws -> ComputePipelineState {
		return try maschine.newComputePipelineState(name: name)
	}
}
extension Context {
	internal func newOptimizer(count: Int) throws -> Optimizer {
		return try optimizer(maschine, count)
	}
}
extension Context {
	internal func new<T: ManagedObject>() -> T? {
		var result: T? = nil
		performAndWait {
			let object: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self)
			if let sametype: T = object as? T {
				result = sametype
			} else {
				self.delete(object)
			}
		}
		return result
	}
	internal func fetch<T: ManagedObject>(attribute: Dictionary<String, Any>) throws -> Array<T> {
		var result: Array<T> = Array<T>()
		var err: Error?
		performAndWait {
			let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: T.entityName)
			request.predicate = attribute.isEmpty ? nil : NSPredicate(format: attribute.keys.map{"\($0) = %@"}.joined(separator: " and "), argumentArray: Array<Any>(attribute.values))
			do {
				result  = try self.fetch(request)
			} catch {
				err = error
			}
		}
		if let err: Error = err {
			throw err
		}
		return result
	}
	public func delete(sync: Bool, object: ManagedObject) {
		( sync ? perform : performAndWait ) {
			self.delete(object)
		}
	}
	public func save(sync: Bool, handler: ((Error)->Void)? = nil) {
		( sync ? perform : performAndWait ) {
			do {
				try self.save()
			} catch {
				handler?(error)
			}
		}
	}
}
public class ManagedObject: NSManagedObject {
	internal var context: Context {
		guard let context: Context = managedObjectContext as? Context else {
			assertionFailure(Context.SystemError.BrokenBundle.rawValue)
			fatalError(Context.SystemError.BrokenBundle.rawValue)
		}
		return context
	}
	internal static var entityName: String {
		guard let entityName: String = String(describing: self).components(separatedBy: ".").last else {
			assertionFailure(Context.SystemError.BrokenBundle.rawValue)
			fatalError(Context.SystemError.BrokenBundle.rawValue)
		}
		return  entityName
	}
	internal func setup(context: Context) throws {
		
	}
	public override func awakeFromFetch() {
		super.awakeFromFetch()
		do {
			try setup(context: context)
		} catch {
			assertionFailure(Context.SystemError.BrokenBundle.rawValue)
		}
	}
	public override func awake(fromSnapshotEvents: NSSnapshotEventType) {
		super.awake(fromSnapshotEvents: fromSnapshotEvents)
		do {
			try setup(context: context)
		} catch {
			assertionFailure(Context.SystemError.BrokenBundle.rawValue)
		}
	}
}
