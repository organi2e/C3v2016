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

public class Context: NSManagedObjectContext {
	
	//I hate fileprivate rather
	internal let maschine: Maschine
	
	public init(storage: URL?) throws {
		self.maschine = try Maschine(device: MTLCreateSystemDefaultDevice())
		super.init(concurrencyType: .privateQueueConcurrencyType)
		try setup(storage: storage)
	}
	public required init?(coder: NSCoder) {
		self.maschine = try!Maschine(device: MTLCreateSystemDefaultDevice())
		super.init(coder: coder)
		try!setup(storage: nil)
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
	internal func newBuffer<T>(count: Int) -> Buffer<T> {
		return maschine.newBuffer(count: count)
	}
	internal func newBuffer<T>(data: Data) -> Buffer<T> {
		return maschine.newBuffer(data: data)
	}
	internal func newComputePipelineState(name: String) throws -> ComputePipelineState {
		return try maschine.newComputePipelineState(name: name)
	}
}
extension Context {
	internal func new<T: ManagedObject>() -> T? {
		var result: T? = nil
		if let entityName: String = String(describing: T.self).components(separatedBy: ".").last {
			performAndWait {
				let object: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self)
				if let sametype: T = object as? T {
					result = sametype
				} else {
					self.delete(object)
				}
			}
		}
		return result
	}
	internal func fetch<T: ManagedObject>(attribute: Dictionary<String, Any>, handler: ((Error)->Void)? = nil) -> Array<T> {
		var result: Array<T> = Array<T>()
		if let entityName: String = String(describing: T.self).components(separatedBy: ".").last {
			performAndWait {
				let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName)
				request.predicate = attribute.isEmpty ? nil : NSPredicate(format: attribute.keys.map{"\($0) = %@"}.joined(separator: " and "), argumentArray: Array<Any>(attribute.values))
				do {
					result  = try self.fetch(request)
				} catch {
					handler?(error)
				}
			}
		}
		return result
	}
	internal func purge(object: ManagedObject, sync: Bool = false) {
		( sync ? perform : performAndWait ) {
			self.delete(object)
		}
	}
	internal func store(sync: Bool = false, handling: ((Error)->Void)? = nil) {
		( sync ? perform : performAndWait ) {
			do {
				try self.save()
			} catch {
				handling?(error)
			}
		}
	}
}
public class ManagedObject: NSManagedObject {
	internal var context: Context {
		guard let context: Context = managedObjectContext as? Context else { fatalError(Context.SystemError.InvalidContext.rawValue) }
		return context
	}
	internal func setup(context: Context) throws {
		
	}
	public override func awakeFromFetch() {
		super.awakeFromFetch()
		if let context: Context = managedObjectContext as? Context {
			do {
				try setup(context: context)
			} catch {
			
			}
		} else {
			assertionFailure(Context.SystemError.InvalidContext.rawValue)
		}
	}
	public override func awake(fromSnapshotEvents flags: NSSnapshotEventType) {
		super.awake(fromSnapshotEvents: flags)
		if let context: Context = managedObjectContext as? Context {
			do {
				try setup(context: context)
			} catch {
				
			}
		} else {
			assertionFailure(Context.SystemError.InvalidContext.rawValue)
		}
	}
}
