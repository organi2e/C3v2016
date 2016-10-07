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
import Optimizer
@testable import C3

class ContextTests: XCTestCase {
	
	let context: Context = try!Context(storage: nil)//URL(fileURLWithPath: "/Users/Kota/test.sqlite"))
	
	static let T: Bool = true
	static let f: Bool = false
	
	//let IS: [[Bool]] = [[f,f,T,f], [f,T,f,f], [f,f,T,f], [f,f,f,T]]
	let IS: [[Bool]] = [[f,T,f,f], [f,f,T,T], [f,f,T,f], [f,f,f,T]]
	//let IS: [[Bool]] = [[T,f,f,f], [f,T,f,f], [f,f,T,f], [f,f,f,T]]
	let OS: [[Bool]] = [[T,f,f,f], [f,T,f,f], [f,f,T,f], [f,f,f,T]]
	
	func testChain() {
		do {
			
			context.optimizer = AdaDelta.factory(α: 1.0, γ: 0.95, ε: 1e-3)
			
			let I: Cell = try context.newCell(type: .Gaussian, width: 4, label: "I")
			let H: Cell = try context.newCell(type: .Gaussian, width: 64, label: "H")
			let G: Cell = try context.newCell(type: .Gaussian, width: 64, label: "G")
			let O: Cell = try context.newCell(type: .Gaussian, width: 4, label: "O")
			
			try context.chain(output: O, input: G)
			try context.chain(output: G, input: H)
			//try context.chain(output: H, input: G)
			try context.chain(output: H, input: I)
			
			
			for k in 0..<65536 {
				
				//print("before \(k)")
				//O.input.first?.dump()
				
				for _ in 0..<1 {
					
					O.collect_clear()
					I.correct_clear()
			
					I.active = IS[k%4]
					O.answer = OS[k%4]
			
					let _ = O.collect()
					let _ = I.correct()
					
				}
				
				//print("after \(k)")
				//O.input.first?.dump()
			
			}
			
			for k in 0..<16 {
				
				O.collect_clear()
				I.correct_clear()
				
				I.active = IS[k%4]
				O.collect()
				
				print(k)
				print(O.active)
				print(O.level.curr.χ)
				
			}
			
		} catch {
			
		}
	}
}
