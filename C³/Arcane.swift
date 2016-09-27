//
//  Arcane.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//
import CoreData
import LaObjet
import Funktion
internal class Arcane: NSManagedObject {
    
    private var n: Buffer!
    private var m: Buffer!
    private var s: Buffer!
    
    func setup() {
		guard let context: Context = managedObjectContext as? Context else { fatalError() }
        
	}
    
    func resize(rows r: UInt, cols c: UInt) {
        let count: Int = Int(rows*cols)
        rows = r
        cols = c
        logmu = Data(bytes: Array<Float>(repeating: 0, count: count), count: MemoryLayout<Float>.size*count)
        logsigma = Data(bytes: Array<Float>(repeating: 0, count: count), count: MemoryLayout<Float>.size*count)
    }
    internal var χ: LaObjet {
        return LaMatrice(valuer: n.contents(), rows: rows, cols: cols, deallocator: nil)
    }
    internal var μ: LaObjet {
        return LaMatrice(valuer: m.contents(), rows: rows, cols: cols, deallocator: nil)
    }
    internal var σ: LaObjet {
        return LaMatrice(valuer: s.contents(), rows: rows, cols: cols, deallocator: nil)
    }
    
}
extension Arcane {
	@NSManaged var rows: UInt
	@NSManaged var cols: UInt
	@NSManaged var logmu: Data
	@NSManaged var logsigma: Data
}
