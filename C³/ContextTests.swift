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
	
	//let IS: [[Bool]] = [[T,f,f,f], [f,T,f,f], [f,f,T,f], [f,T,f,f]]
	let IS: [[Bool]] = [[f,T,f,f], [f,f,T,T], [f,f,T,f], [f,f,f,T]]
	//let IS: [[Bool]] = [[T,f,f,f], [f,T,f,f], [f,f,T,f], [f,f,f,T]]
	let OS: [[Bool]] = [[T,f,f,f], [f,T,f,f], [f,f,T,f], [f,f,f,T]]
	
	func testChain() {
		do {
			
			context.optimizer = AdaDelta.factory(α: 1, γ: 0.95, ε: 1e-4)
			
			let I: Cell = try context.newCell(type: .Gaussian, width: 4, label: "I")
			let H: Cell = try context.newCell(type: .Gaussian, width: 16, label: "H")
			let G: Cell = try context.newCell(type: .Gaussian, width: 16, label: "G")
			let O: Cell = try context.newCell(type: .Gaussian, width: 4, label: "O")
			
			try context.chain(output: O, input: G)
			try context.chain(output: G, input: H)
			//try context.chain(output: H, input: G)
			try context.chain(output: H, input: I)
			
			for i in 0..<8192 {
				
				//print("before \(k)")
				//O.input.first?.dump()
				
				for _ in 0..<8 {
					
					O.collect_clear()
					I.correct_clear()
			
					I.active = IS[i%4]
					O.answer = OS[i%4]
			
					let _ = O.collect()
					let _ = I.correct()
					
				}
				
				//print("after \(k)")
				//O.input.first?.dump()
			
				if i % 64 == 0 {
					print(i/64)
				}
				
			}
			
			for k in 0..<8 {
				
				print(k)
				
				for _ in 0..<8 {
					O.collect_clear()
					I.correct_clear()
					
					I.active = IS[k%4]
					O.collect()
				
					print(O.active.enumerated().map { k % 4 == $0.offset ? "[\($0.element)]" : "\($0.element)" }, O.level.curr.χ)
				}
				
			}
			
		} catch {
			
		}
	}
}
