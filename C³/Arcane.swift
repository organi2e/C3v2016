//
//  Arcane.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//
import CoreData
internal class Arcane: NSManagedObject {

	func setup() {
		guard let context: Context = managedObjectContext as? Context else { fatalError() }
	}
}
extension Arcane {
	@NSManaged var rows: UInt64
	@NSManaged var cols: UInt64
	@NSManaged var logmu: Data
	@NSManaged var logsigma: Data
}
