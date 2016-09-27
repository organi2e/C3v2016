//
//  Cell.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import LaObjet
import Funktion
import Distribution
import CoreData
public class Cell: NSManagedObject {
}
extension Cell {
	public func collect(ignore: Set<Cell> = []) -> LaObjet {
		input.map {
			$0.collect(ignore: ignore.union([self]))
		}
		return LaMatrice(identité: 1)
	}
	public func correct(ignore: Set<Cell> = []) -> (Δ: LaObjet, gradμ: LaObjet, gradσ: LaObjet) {
		return (
			Δ: LaMatrice(valuer: 0),
			gradμ: LaMatrice(valuer: 0),
			gradσ: LaMatrice(valuer: 0)
		)
	}
}
extension Cell {
	@NSManaged var width: UInt
	@NSManaged var input: Set<Cell>
	@NSManaged var output: Set<Cell>
}
extension Cell {
	internal var state: LaObjet {
		return LaMatrice(valuer: 0)
	}
}
