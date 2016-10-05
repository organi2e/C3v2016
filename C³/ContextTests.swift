//
//  ContextTests.swift
//  C³
//
//  Created by Kota on 10/3/16.
//
//

import XCTest
import C3

class ContextTests: XCTestCase {
	func testContext() {
		do {
			let context: Context = try Context(storage: nil)//URL(fileURLWithPath: "/Users/Kota/test.sqlite"))
			let _: Cell = try context.newCell(type: .Degenerate, width: 10)
			let _: Cell = try context.newCell(type: .Degenerate, width: 12)
			let _: Cell = try context.newCell(type: .Cauchy, width: 14)
			try context.save()
			let restore: [Cell] = try context.searchCell(type: .Cauchy)
			print(restore)
		} catch {
			XCTFail()
		}
	}
	func testChain() {
		do {
			let context: Context = try Context(storage: nil)//URL(fileURLWithPath: "/Users/Kota/test.sqlite"))
			let I: Cell = try context.newCell(type: .Degenerate, width: 10)
			let O: Cell = try context.newCell(type: .Degenerate, width: 10, input: [I])
			
			O.collect_clear()
			context.save(sync: false)
			
		} catch {
			
		}
	}
}
