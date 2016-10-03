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
			let context: Context = try Context(storage: URL(fileURLWithPath: "/Users/Kota/test.sqlite"))
			let cell: Cell = try context.newCell(width: 10)
			print(cell)
		} catch {
			XCTFail()
		}
	}
}
