//
//  LaSparse.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//

import Accelerate

typealias LaSparseObjet = sparse_matrix_float

extension LaSparseObjet {
	var rows: Int {
		var ref: sparse_matrix_float = self
		return Int(sparse_get_matrix_number_of_rows(&ref))
	}
	var cols: Int {
		var ref: sparse_matrix_float = self
		return Int(sparse_get_matrix_number_of_columns(&ref))
	}
}
extension LaSparseObjet {
	subscript(row: Int, col: Int) -> Float {
		get {
			return 0
		}
		set {
			
		}
	}
	subscript(rows: Int, cols: Int) -> [Float] {
		get {
			return []
		}
		set {
			
		}
	}
	func insert(buffer: UnsafeRawPointer, row: Int, col: Int) {
		sparse_insert_block_float(self, UnsafePointer<Float>(OpaquePointer(buffer)), 1, 1, sparse_index(row), sparse_index(col))
	}
}
func LaSparse(rows: Int, cols: Int) -> LaSparseObjet {
	return sparse_matrix_create_float(sparse_dimension(rows), sparse_dimension(cols))
}
