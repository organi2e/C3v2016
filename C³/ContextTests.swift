//
//  ContextTests.swift
//  C³
//
//  Created by Kota on 10/3/16.
//
//

import XCTest
import LaObjet
import Maschine
@testable import C3

class ContextTests: XCTestCase {
	
	let context: Context = try!Context(storage: nil)//URL(fileURLWithPath: "/Users/Kota/test.sqlite"))
	
	static let T: Bool = true
	static let f: Bool = false
	
	let IS: [[Bool]] = [[f,f,f,T], [f,f,T,f], [f,T,f,f], [T,f,f,f]]
	let OS: [[Bool]] = [[f,f,f,T], [f,f,T,f], [f,T,f,f], [T,f,f,f]]
	
	func testChain() {
		do {
			let I: Cell = try context.newCell(type: .Degenerate, width: 4, label: "I")
			let O: Cell = try context.newCell(type: .Degenerate, width: 4, label: "O", input: [I])
			
			for k in 0..<256 {
				
				print("before \(k)")
				O.input.first?.dump()
				
				for k in 0..<4 {
				
					O.collect_clear()
					I.correct_clear()
			
					I.active = IS[k%4]
					O.answer = OS[k%4]
			
					O.collect()
					I.correct()
					
					print(O.level.curr.χ.array)
					print(O.state.curr.array)
				}
				
				print("after \(k)")
				O.input.first?.dump()
				
				
			}
			
			for k in 0..<4 {
				
				O.collect_clear()
				I.correct_clear()
				
				I.active = IS[k%4]
				O.collect()
				
				print(k)
				print(O.level.curr.χ.array)
				print(O.state.curr.array)
				
			}
			
		} catch {
			
		}
	}
}
