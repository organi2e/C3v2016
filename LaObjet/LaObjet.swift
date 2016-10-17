//
//  LaDense.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//

import Accelerate

//An implementation of Linear algebra container
// with lazy evaluation
// with semi-broadcasting (not vector and matrix but scalar and matrix)

private let ATTR: la_attribute_t = la_attribute_t(LA_ATTRIBUTE_ENABLE_LOGGING)
private let HINT: la_hint_t = la_hint_t(LA_NO_HINT)
private let NOHINT: la_hint_t = la_hint_t(LA_NO_HINT)
private let SUCCESS: la_status_t = la_status_t(LA_SUCCESS)

public struct LaObjet<Type: LaType> {
	internal let objet: la_object_t
	internal init(objet: la_object_t) {
		self.objet = objet
	}
	public init(valuer: Type.Élément) {
		objet = Type.matriceSplat(valuer, ATTR)
	}
	public init<Entier: Integer>(identité: Entier) {
		objet = la_identity_matrix(identité.unsignedValue, Type.matriceType, ATTR)
	}
	public init<Entier: Integer>(diagonale: LaObjet, shift: Entier = 0) {
		objet = la_diagonal_matrix_from_vector(diagonale.objet, shift.signedValue)
	}
	public init<Entier: Integer>(valuer: Type.Élément, rows: Entier, cols: Entier = 1) {
		objet = la_matrix_from_splat(Type.matriceSplat(valuer, ATTR), rows.unsignedValue, cols.unsignedValue)
	}
	public init<Entier: Integer>(valuer: UnsafePointer<Type.Élément>, rows: Entier, cols: Entier, stride: Entier? = nil) {
		objet = Type.matriceCopy(valuer, rows.unsignedValue, cols.unsignedValue, (stride ?? cols).unsignedValue, HINT, ATTR)
	}
	public init<Entier: Integer>(valuer: UnsafePointer<Type.Élément>, rows: Entier, cols: Entier, stride: Entier? = nil, deallocator: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?) {
		objet = Type.matriceNocopy(UnsafeMutablePointer<Type.Élément>(OpaquePointer(valuer)), rows.unsignedValue, cols.unsignedValue, (stride ?? cols).unsignedValue, HINT, deallocator, ATTR)
	}
	public var colsdiag: LaObjet {
		let rows: UInt = la_matrix_rows(objet)
		let cols: UInt = la_matrix_cols(objet)
		let buffer: UnsafeMutablePointer<Type.Élément> = UnsafeMutablePointer<Type.Élément>(OpaquePointer(calloc(Int(rows*rows*cols), MemoryLayout<Type.Élément>.size)))
		assert(Type.matriceBytes(buffer, (rows+1)*cols, objet)==SUCCESS)
		return LaObjet(objet: Type.matriceNocopy(buffer, rows, rows*cols, rows*cols, NOHINT, { free($0) }, ATTR))
	}
	public var array: Array<Type.Élément> {
		let rows: la_count_t = la_matrix_rows(objet)
		let cols: la_count_t = la_matrix_cols(objet)
		let result: Array<Type.Élément> = Array<Type.Élément>(repeating: 0, count: max(1, Int(rows*cols)))
		assert(Type.matriceBytes(UnsafeMutablePointer<Type.Élément>(OpaquePointer(result)), cols, rows == 0 && cols == 0 ? la_matrix_from_splat(objet, 1, 1) : objet)==SUCCESS)
		return result
	}
	public func value<Entier: Integer>(at: Entier) -> Type.Élément {
		let rows: la_count_t = la_matrix_rows(objet)
		let cols: la_count_t = la_matrix_cols(objet)
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat( rows == 0 && cols == 0 ? objet : la_splat_from_vector_element(objet, at.signedValue), 1, 1))==SUCCESS)//Avoid redundant computation
		return value
	}
	public func value<Entier: Integer>(at: (row: Entier, col: Entier)) -> Type.Élément {
		let rows: la_count_t = la_matrix_rows(objet)
		let cols: la_count_t = la_matrix_cols(objet)
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat( rows == 0 && cols == 0 ? objet : la_splat_from_matrix_element(objet, at.0.signedValue, at.1.signedValue), 1, 1))==SUCCESS)//Avoid redundant computation
		return value
	}
	public func copy(to: UnsafePointer<Type.Élément>) -> Bool {
		return Type.matriceBytes(UnsafeMutablePointer<Type.Élément>(OpaquePointer(to)), cols, objet) == SUCCESS
	}
	public var L1Norme: Type.Élément {
		return Type.matriceNormé(objet, la_norm_t(LA_L1_NORM))
	}
	public var L1Normalisée: LaObjet {
		return LaObjet(objet: la_normalized_vector(objet, la_norm_t(LA_L1_NORM)))
	}
	public var L2Norme: Type.Élément {
		return Type.matriceNormé(objet, la_norm_t(LA_L2_NORM))
	}
	public var L2Normalisée: LaObjet {
		return LaObjet(objet: la_normalized_vector(objet, la_norm_t(LA_L2_NORM)))
	}
	public var LINFNorme: Type.Élément {
		return Type.matriceNormé(objet, la_norm_t(LA_LINF_NORM))
	}
	public var LINFNormalisée: LaObjet {
		return LaObjet(objet: la_normalized_vector(objet, la_norm_t(LA_LINF_NORM)))
	}
	public var rows: UInt {
		return la_matrix_rows(objet)
	}
	public var cols: UInt {
		return la_matrix_cols(objet)
	}
	public var count: UInt {
		return la_matrix_rows(objet) * la_matrix_cols(objet)
	}
	public var status: Int {
		return Int(la_status(objet))
	}
	public var T: LaObjet {
		return LaObjet(objet: la_transpose(objet))
	}
	public var length: UInt {
		return la_vector_length(objet)
	}
	public subscript(index: Int) -> LaObjet {
		return LaObjet(objet: la_splat_from_vector_element(objet, index))
	}
	public subscript(row: Int, col: Int) -> LaObjet {
		return LaObjet(objet: la_splat_from_matrix_element(objet, row, col))
	}
	public subscript(range: Range<Int>) -> LaObjet {
		return LaObjet(objet: la_vector_slice(objet, range.lowerBound, 1, la_count_t(range.count)))
	}
	public var statistics: (μ: Type.Élément, σ: Type.Élément) {
		var μ: Type.Élément = 0
		var σ: Type.Élément = 0
		Type.vecteurStatistics(array, 1, nil, 0, &μ, &σ, la_matrix_rows(objet)*la_matrix_cols(objet))
		return(μ: μ, σ: σ)
	}
	public subscript(rows: Range<Int>, cols: Range<Int>) -> LaObjet {
		return LaObjet(objet: la_matrix_slice(objet, rows.lowerBound, cols.lowerBound, la_index_t(la_matrix_cols(objet)), 1, la_count_t(rows.count), la_count_t(cols.count)))
	}
	func rowVecteur<Entier: Integer>(col: Entier) -> LaObjet {
		return LaObjet(objet: la_vector_from_matrix_row(objet, col.unsignedValue))
	}
	func colVecteur<Entier: Integer>(row: Entier) -> LaObjet {
		return LaObjet(objet: la_vector_from_matrix_col(objet, row.unsignedValue))
	}
	func diagVecteur<Entier: Integer>(offset: Entier) -> LaObjet {
		return LaObjet(objet: la_vector_from_matrix_diagonal(objet, offset.signedValue))
	}
}

extension LaObjet where Type: LaSoloType {
	public func toDoublé() -> LaObjet<Double> {
		let rows: UInt = la_matrix_rows(objet)
		let cols: UInt = la_matrix_cols(objet)
		let length: UInt = rows * cols
		let count: Int = Int(length)
		let dst: UnsafeMutablePointer<Double> = UnsafeMutablePointer<Double>(OpaquePointer(malloc(MemoryLayout<Double>.size*count)))
		let src: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: count)
		defer { src.deallocate(capacity: count) }
		assert(la_matrix_to_float_buffer(src, cols, objet)==SUCCESS)
		vDSP_vspdp(src, 1, dst, 1, length)
		return LaObjet<Double>(valuer: dst, rows: rows, cols: cols, deallocator: { free($0) })
	}
}
extension LaObjet where Type: LaDoubléType {
	public func toSolo() -> LaObjet<Float> {
		let rows: UInt = la_matrix_rows(objet)
		let cols: UInt = la_matrix_cols(objet)
		let length: UInt = rows * cols
		let count: Int = Int(length)
		let dst: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>(OpaquePointer(malloc(MemoryLayout<Float>.size*count)))
		let src: UnsafeMutablePointer<Double> = UnsafeMutablePointer<Double>.allocate(capacity: count)
		defer { src.deallocate(capacity: count) }
		assert(la_matrix_to_double_buffer(src, cols, objet)==SUCCESS)
		vDSP_vdpsp(src, 1, dst, 1, length)
		return LaObjet<Float>(valuer: dst, rows: rows, cols: cols, deallocator: { free($0) })
	}
}
// MARK: - Minus
public prefix func-<Type: FloatingPoint>(lhs: LaObjet<Type>) -> LaObjet<Type> {
	if lhs.count == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(-value, ATTR))
	} else {
		return LaObjet<Type>(objet: Type.matriceÉchelle(lhs.objet, -1))
	}
}

// MARK: - Addition
public func +<Type: FloatingPoint>(lhs: LaObjet<Type>, rhs: LaObjet<Type>) -> LaObjet<Type> {
	let lhscount: UInt = lhs.count
	let rhscount: UInt = rhs.count
	if lhscount == 0 && rhscount == 0 {
		var x: Type.Élément = 0
		var y: Type.Élément = 0
		assert(Type.matriceBytes(&x, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		assert(Type.matriceBytes(&y, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(x+y, ATTR))
	} else if lhscount == 1 && rhscount == 1 {
		return LaObjet(objet: la_sum(lhs.objet, rhs.objet))
	} else {
		return LaObjet(objet: la_sum(lhscount == 1 ? la_splat_from_matrix_element(lhs.objet, 0, 0) : lhs.objet, rhscount == 1 ? la_splat_from_matrix_element(rhs.objet, 0, 0) : rhs.objet))
	}
}
public func +<Type: FloatingPoint>(lhs: LaObjet<Type>, rhs: Type.Élément) -> LaObjet<Type> {
	if lhs.count == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(value+rhs, ATTR))
	} else {
		return LaObjet<Type>(objet: la_sum(lhs.objet, Type.matriceSplat(rhs, ATTR)))
	}
}
public func +<Type: FloatingPoint>(lhs: Type.Élément, rhs: LaObjet<Type>) -> LaObjet<Type> {
	if rhs.count == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(lhs+value, ATTR))
	} else {
		return LaObjet<Type>(objet: la_sum(Type.matriceSplat(lhs, ATTR), rhs.objet))
	}
}

// MARK: - Subtraction
public func -<Type: FloatingPoint>(lhs: LaObjet<Type>, rhs: LaObjet<Type>) -> LaObjet<Type> {
	let lhscount: UInt = lhs.count
	let rhscount: UInt = rhs.count
	if lhscount == 0 && rhscount == 0 {
		var x: Type.Élément = 0
		var y: Type.Élément = 0
		assert(Type.matriceBytes(&x, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		assert(Type.matriceBytes(&y, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(x-y, ATTR))
	} else if lhscount == 1 && rhscount == 1 {
		return LaObjet(objet: la_difference(lhs.objet, rhs.objet))
	} else {
		return LaObjet(objet: la_difference(lhscount == 1 ? la_splat_from_matrix_element(lhs.objet, 0, 0) : lhs.objet, rhscount == 1 ? la_splat_from_matrix_element(rhs.objet, 0, 0) : rhs.objet))
	}
}
public func -<Type: FloatingPoint>(lhs: LaObjet<Type>, rhs: Type.Élément) -> LaObjet<Type> {
	if lhs.count == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(value-rhs, ATTR))
	} else {
		return LaObjet<Type>(objet: la_difference(lhs.objet, Type.matriceSplat(rhs, ATTR)))
	}
}
public func -<Type: FloatingPoint>(lhs: Type.Élément, rhs: LaObjet<Type>) -> LaObjet<Type> {
	if rhs.count == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(lhs-value, ATTR))
	} else {
		return LaObjet<Type>(objet: la_sum(Type.matriceSplat(lhs, ATTR), rhs.objet))
	}
}

// MARK: - Multiplication
public func *<Type: FloatingPoint>(lhs: LaObjet<Type>, rhs: LaObjet<Type>) -> LaObjet<Type> {
	let lhscount: UInt = lhs.count
	let rhscount: UInt = rhs.count
	if lhscount == 0 && rhscount == 0 {
		var x: Type.Élément = 0
		var y: Type.Élément = 0
		assert(Type.matriceBytes(&x, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		assert(Type.matriceBytes(&y, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		return LaObjet(objet: Type.matriceSplat(x*y, ATTR))
	} else if lhscount == 1 && rhscount == 1 {
		return LaObjet(objet: la_elementwise_product(lhs.objet, rhs.objet))
	} else {
		return LaObjet(objet: la_elementwise_product(lhscount == 1 ? la_splat_from_matrix_element(lhs.objet, 0, 0) : lhs.objet, rhscount == 1 ? la_splat_from_matrix_element(rhs.objet, 0, 0) : rhs.objet))
	}
}
public func *<Type: FloatingPoint>(lhs: LaObjet<Type>, rhs: Type.Élément) -> LaObjet<Type> {
	if lhs.count == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(value*rhs, ATTR))
	}
	else {
		return LaObjet<Type>(objet: Type.matriceÉchelle(lhs.objet, rhs))
	}
}
public func *<Type: FloatingPoint>(lhs: Type.Élément, rhs: LaObjet<Type>) -> LaObjet<Type> {
	if rhs.count == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(value*lhs, ATTR))
	} else {
		return LaObjet<Type>(objet: Type.matriceÉchelle(rhs.objet, lhs))
	}
}

// MARK: - Division
//		 - fire vvdiv and employ vvrec for lazy evaluation
public func /<Type: FloatingPoint>(lhs: LaObjet<Type>, rhs: LaObjet<Type>) -> LaObjet<Type> {
	let lhscount: UInt = lhs.count
	let rhsrows: UInt = la_matrix_rows(rhs.objet)
	let rhscols: UInt = la_matrix_cols(rhs.objet)
	let rhscount: UInt = rhsrows * rhscols
	if lhscount == 0 && rhscount == 0 { // return splat
		var y: Type.Élément = 0
		var x: Type.Élément = 1
		assert(Type.matriceBytes(&x, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		assert(Type.matriceBytes(&y, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(y/x, ATTR))
	} else if lhscount != 0 && rhscount == 0 {
		var x: Type.Élément = 1
		assert(Type.matriceBytes(&x, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceÉchelle(lhs.objet, 1/x))
	} else if lhscount != 0 && rhscount == 1 {
		var x: Type.Élément = 1
		assert(Type.matriceBytes(&x, 1, rhs.objet)==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceÉchelle(lhs.objet, 1/x))
	} else {
		let result: UnsafeMutablePointer<Type.Élément> = UnsafeMutablePointer<Type.Élément>(OpaquePointer(malloc_zone_malloc(malloc_default_zone(), MemoryLayout<Type.Élément>.size*Int(rhscount))))
		assert(Type.matriceBytes(result, rhscols, rhs.objet)==SUCCESS)
		Type.vecteurRec(result, result, [Int32(rhscount)])
		return LaObjet<Type>(objet: la_elementwise_product(lhscount == 1 ? la_splat_from_matrix_element(lhs.objet, 0, 0) : lhs.objet, Type.matriceNocopy(result, rhsrows, rhscols, rhscols, HINT, { malloc_zone_free(malloc_default_zone(), $0) }, ATTR)))
	}
}
public func /<Type: FloatingPoint>(lhs: LaObjet<Type>, rhs: Type.Élément) -> LaObjet<Type> {
	let lhscount: UInt = lhs.count
	if lhscount == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(lhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(value/rhs, ATTR))
	} else {
		return LaObjet<Type>(objet: Type.matriceÉchelle(lhs.objet, 1/rhs))
	}
}
public func /<Type: FloatingPoint>(lhs: Type.Élément, rhs: LaObjet<Type>) -> LaObjet<Type> {
	let rhsrows: UInt = la_matrix_rows(rhs.objet)
	let rhscols: UInt = la_matrix_rows(rhs.objet)
	let rhscount: UInt = rhsrows * rhscols
	if rhscount == 0 {
		var value: Type.Élément = 0
		assert(Type.matriceBytes(&value, 1, la_matrix_from_splat(rhs.objet, 1, 1))==SUCCESS)
		return LaObjet<Type>(objet: Type.matriceSplat(lhs/value, ATTR))
	} else {
		let result: UnsafeMutablePointer<Type.Élément> = UnsafeMutablePointer<Type.Élément>(OpaquePointer(malloc_zone_malloc(malloc_default_zone(), MemoryLayout<Type.Élément>.size*Int(rhscount))))
		assert(Type.matriceBytes(result, rhscols, rhs.objet)==SUCCESS)
		Type.vecteurRec(result, result, [Int32(rhscount)])
		return LaObjet<Type>(objet: Type.matriceÉchelle(Type.matriceNocopy(result, rhsrows, rhscols, rhscols, HINT, { malloc_zone_free(malloc_default_zone(), $0) }, ATTR), lhs))
	}
}

// MARK: - Linear Algebra productions
public func inner_product<T: FloatingPoint>(_ lhs: LaObjet<T>, _ rhs: LaObjet<T>) -> LaObjet<T> {
	return LaObjet<T>(objet: la_inner_product(lhs.objet, rhs.objet))
}
public func outer_product<T: FloatingPoint>(_ lhs: LaObjet<T>, _ rhs: LaObjet<T>) -> LaObjet<T> {
	return LaObjet<T>(objet: la_outer_product(lhs.objet, rhs.objet))
}
public func matrix_product<T: FloatingPoint>(_ lhs: LaObjet<T>, _ rhs: LaObjet<T>) -> LaObjet<T> {
	return LaObjet<T>(objet: la_matrix_product(lhs.objet, rhs.objet))
}
public func solve<T: FloatingPoint>(A: LaObjet<T>, b: LaObjet<T>) -> LaObjet<T> {
	return LaObjet<T>(objet: la_solve(A.objet, b.objet))
}
