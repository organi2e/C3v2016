//
//  LaDense.swift
//  C³
//
//  Created by Kota Nakano on 9/21/16.
//
//

import Accelerate

private let ATTR: la_attribute_t = la_attribute_t(LA_ATTRIBUTE_ENABLE_LOGGING)
private let HINT: la_hint_t = la_hint_t(LA_NO_HINT)
private let TYPE: la_scalar_type_t = la_scalar_type_t(LA_SCALAR_TYPE_FLOAT)
private let SUCCESS: la_status_t = la_status_t(LA_SUCCESS)

public typealias LaObjet = la_object_t

public class Objet<T: FloatingPoint> {
	
	internal typealias objet = la_object_t
	internal let objet: objet
	internal init(objet: objet) {
		self.objet = objet
	}
	var rows: UInt {
		return la_matrix_rows(self.objet)
	}
	var cols: UInt {
		return la_matrix_cols(self.objet)
	}
	var count: UInt {
		return la_matrix_rows(self.objet) * la_matrix_cols(self.objet)
	}
}
func La(n: Int) -> Objet<Float> {
	let my: la_object_t = la_splat_from_float(0, ATTR)
	return Objet<Float>(objet: my)
}
func La(n: Int) -> Objet<Double> {
	let my: la_object_t = la_splat_from_double(0, ATTR)
	return Objet<Double>(objet: my)
}

public extension LaObjet {
	var rows: UInt {
		return la_matrix_rows(self)
	}
	var cols: UInt {
		return la_matrix_cols(self)
	}
	var count: UInt {
		return la_matrix_rows(self) * la_matrix_cols(self)
	}
	var status: Int {
		return Int(la_status(self))
	}
	var T: LaObjet {
		return la_transpose(self)
	}
	var length: UInt {
		return la_vector_length(self)
	}
	var L1Norme: Float {
		return la_norm_as_float(self, la_norm_t(LA_L1_NORM))
	}
	var L2Norme: Float {
		return la_norm_as_float(self, la_norm_t(LA_L2_NORM))
	}
	var LINFNorme: Float {
		return la_norm_as_float(self, la_norm_t(LA_LINF_NORM))
	}
	var eval: [Float] {
		let rows: la_count_t = la_matrix_rows(self)
		let cols: la_count_t = la_matrix_cols(self)
		let result: [Float] = [Float](repeating: 0, count: max(1, Int(rows*cols)))
		assert(la_matrix_to_float_buffer(UnsafeMutablePointer<Float>(mutating: result), cols, rows == 0 && cols == 0 ? la_matrix_from_splat(self, 1, 1) : self)==SUCCESS)
		return result
	}
    func value<Entier: Integer>(at: Entier) -> Float {
		let rows: la_count_t = la_matrix_rows(self)
		let cols: la_count_t = la_matrix_cols(self)
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat( rows == 0 && cols == 0 ? self : la_splat_from_vector_element(self, at.signedValue), 1, 1))==SUCCESS)//Avoid redundant computation
		return value
	}
    func value<Entier: Integer>(at: (row: Entier, col: Entier)) -> Float {
		let rows: la_count_t = la_matrix_rows(self)
		let cols: la_count_t = la_matrix_cols(self)
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat( rows == 0 && cols == 0 ? self : la_splat_from_matrix_element(self, at.0.signedValue, at.1.signedValue), 1, 1))==SUCCESS)//Avoid redundant computation
		return value
	}
	subscript(index: Int) -> LaObjet {
		return la_splat_from_vector_element(self, index)
	}
	subscript(row: Int, col: Int) -> LaObjet {
		return la_splat_from_matrix_element(self, row, col)
	}
	subscript(range: Range<Int>) -> LaObjet {
		return la_vector_slice(self, range.lowerBound, 1, la_count_t(range.count))
	}
	subscript(rows: Range<Int>, cols: Range<Int>) -> LaObjet {
		return la_matrix_slice(self, rows.lowerBound, cols.lowerBound, la_index_t(la_matrix_cols(self)), 1, la_count_t(rows.count), la_count_t(cols.count))
	}
	func getBytes(buffer: UnsafeRawPointer) -> Bool {
		return la_matrix_to_float_buffer(UnsafeMutablePointer<Float>(OpaquePointer(buffer)), la_matrix_cols(self), self) == SUCCESS
	}
    func rowVecteur<Entier: Integer>(col: Entier) -> LaObjet {
		return la_vector_from_matrix_row(self, col.unsignedValue)
	}
    func colVecteur<Entier: Integer>(row: Entier) -> LaObjet {
		return la_vector_from_matrix_col(self, row.unsignedValue)
	}
    func diagVecteur<Entier: Integer>(offset: Entier) -> LaObjet {
		return la_vector_from_matrix_diagonal(self, offset.signedValue)
	}
}

// MARK: - Minus
public prefix func -(lhs: LaObjet) -> LaObjet {
	if lhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		return la_splat_from_float(-value, ATTR)
	} else {
		return la_scale_with_float(lhs, -1)
	}
}

// MARK: - Addition
public func +(lhs: LaObjet, rhs: LaObjet) -> LaObjet {
	if lhs.count == 0 && rhs.count == 0 {
		var x: Float = 0
		var y: Float = 0
		assert(la_matrix_to_float_buffer(&x, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		assert(la_matrix_to_float_buffer(&y, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_splat_from_float(x+y, ATTR)
	} else {
		return la_sum(lhs, rhs)
	}
}
public func +(lhs: LaObjet, rhs: Float) -> LaObjet {
	if lhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		return la_splat_from_float(value+rhs, ATTR)
	} else {
		return la_sum(lhs, la_splat_from_float(rhs, ATTR))
	}
}
public func +(lhs: Float, rhs: LaObjet) -> LaObjet {
	if rhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_splat_from_float(lhs+value, ATTR)
	} else {
		return la_sum(la_splat_from_float(lhs, ATTR), rhs)
	}
}

// MARK: - Subtraction
public func -(lhs: LaObjet, rhs: LaObjet) -> LaObjet {
	if lhs.count == 0 && rhs.count == 0 {
		var x: Float = 0
		var y: Float = 0
		assert(la_matrix_to_float_buffer(&x, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		assert(la_matrix_to_float_buffer(&y, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_splat_from_float(x-y, ATTR)
	} else {
		return la_difference(lhs, rhs)
	}
}
public func -(lhs: LaObjet, rhs: Float) -> LaObjet {
	if lhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		return la_splat_from_float(value-rhs, ATTR)
	} else {
		return la_difference(lhs, la_splat_from_float(rhs, ATTR))
	}
}
public func -(lhs: Float, rhs: LaObjet) -> LaObjet {
	if rhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_splat_from_float(lhs-value, ATTR)
	} else {
		return la_sum(la_splat_from_float(lhs, ATTR), rhs)
	}
}

// MARK: - Multiplication
public func *(lhs: LaObjet, rhs: LaObjet) -> LaObjet {
    let lhscount: UInt = lhs.count
    let rhscount: UInt = rhs.count
	if lhscount == 0 && rhscount == 0 {
		var x: Float = 0
		var y: Float = 0
		assert(la_matrix_to_float_buffer(&x, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		assert(la_matrix_to_float_buffer(&y, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_splat_from_float(x*y, ATTR)
	} else if lhscount == 1 && rhscount == 1 {
		return la_elementwise_product(lhs, rhs)
	} else {
		return la_elementwise_product(lhscount == 1 ? la_splat_from_matrix_element(lhs, 0, 0) : lhs, rhscount == 1 ? la_splat_from_matrix_element(rhs, 0, 0) : rhs)
	}
}
public func *(lhs: LaObjet, rhs: Float) -> LaObjet {
	if lhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		return la_splat_from_float(value*rhs, ATTR)
	}
	else {
		return la_scale_with_float(lhs, rhs)
	}
}
public func *(lhs: Float, rhs: LaObjet) -> LaObjet {
	if rhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_splat_from_float(value*lhs, ATTR)
	} else {
		return la_scale_with_float(rhs, lhs)
	}
}

// MARK: - Division
//		 - fire vvdiv and employ vvrec for lazy evaluation
public func /(lhs: LaObjet, rhs: LaObjet) -> LaObjet {
	if lhs.count == 0 && rhs.count == 0 { // return splat
		var y: Float = 0
		var x: Float = 1
		assert(la_matrix_to_float_buffer(&y, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		assert(la_matrix_to_float_buffer(&x, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_splat_from_float(y/x, ATTR)
	} else if lhs.count != 0 && rhs.count == 0 {
		var x: Float = 1
		assert(la_matrix_to_float_buffer(&x, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_scale_with_float(lhs, 1/x)
	} else if lhs.count != 0 && rhs.count == 1 {
		var x: Float = 1
		assert(la_matrix_to_float_buffer(&x, 1, rhs)==SUCCESS)
		return la_scale_with_float(lhs, 1/x)
	} else {
		let result: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>(OpaquePointer(malloc_zone_malloc(malloc_default_purgeable_zone(), MemoryLayout<Float>.size*Int(rhs.count))))
        
		assert(la_matrix_to_float_buffer(result, la_matrix_cols(rhs), rhs)==SUCCESS)
		vvrecf(result, result, [Int32(rhs.count)])
        return la_elementwise_product(lhs.count == 1 ? la_splat_from_matrix_element(lhs, 0, 0) : lhs, la_matrix_from_float_buffer_nocopy(result, la_matrix_rows(rhs), la_matrix_cols(rhs), la_matrix_cols(rhs), HINT, { malloc_zone_free(malloc_default_purgeable_zone(), $0) }, ATTR))
	}
}
public func /(lhs: LaObjet, rhs: Float) -> LaObjet {
	if lhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(lhs, 1, 1))==SUCCESS)
		return la_splat_from_float(value/rhs, ATTR)
	} else {
		return la_scale_with_float(lhs, 1/rhs)
	}
}
public func /(lhs: Float, rhs: LaObjet) -> LaObjet {
	if rhs.count == 0 {
		var value: Float = 0
		assert(la_matrix_to_float_buffer(&value, 1, la_matrix_from_splat(rhs, 1, 1))==SUCCESS)
		return la_splat_from_float(lhs/value, ATTR)
	} else {
		let result: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>(OpaquePointer(malloc_zone_malloc(malloc_default_zone(), MemoryLayout<Float>.size*Int(rhs.count))))
		assert(la_matrix_to_float_buffer(result, la_matrix_cols(rhs), rhs)==SUCCESS)
		vvrecf(result, result, [Int32(rhs.count)])
		return la_scale_with_float(la_matrix_from_float_buffer_nocopy(result, la_matrix_rows(rhs), la_matrix_cols(rhs), la_matrix_cols(rhs), HINT, { malloc_zone_free(malloc_default_zone(), $0) }, ATTR), lhs)
	}
}

// MARK: - Normalization
public func L1Normalize(_ x: LaObjet) -> LaObjet {
	return la_normalized_vector(x, la_norm_t(LA_L1_NORM))
}
public func L2Normalize(_ x: LaObjet) -> LaObjet {
	return la_normalized_vector(x, la_norm_t(LA_L2_NORM))
}
public func LINFNormalize(_ x: LaObjet) -> LaObjet {
	return la_normalized_vector(x, la_norm_t(LA_LINF_NORM))
}

// MARK: - Linear Algebra productions
public func inner_product(_ lhs: LaObjet, _ rhs: LaObjet) -> LaObjet {
	return la_inner_product(lhs, rhs)
}
public func outer_product(_ lhs: LaObjet, _ rhs: LaObjet) -> LaObjet {
	return la_outer_product(lhs, rhs)
}
public func matrix_product(_ lhs: LaObjet, _ rhs: LaObjet) -> LaObjet {
	return la_matrix_product(lhs, rhs)
}
public func solve(A: LaObjet, b: LaObjet) -> LaObjet {
	return la_solve(A, b)
}

// MARK: - Build
public func LaMatrice<Entier: Integer>(identité: Entier) -> LaObjet {
	return la_identity_matrix(identité.unsignedValue, TYPE, ATTR)
}
public func LaMatrice<Entier: Integer>(diagonale: LaObjet, shift: Entier = 0) -> LaObjet {
	return la_diagonal_matrix_from_vector(diagonale, shift.signedValue)
}
public func LaMatrice(valuer: Float) -> LaObjet {
	return la_splat_from_float(valuer, ATTR)
}
public func LaMatrice<Entier: Integer>(valuer: Float, rows: Entier, cols: Entier) -> LaObjet {
	return la_matrix_from_splat(la_splat_from_float(valuer, ATTR), rows.unsignedValue, cols.unsignedValue)
}
public func LaMatrice<Entier: Integer>(valuer: Data, rows: Entier, cols: Entier, stride: Entier? = nil) -> LaObjet {
	return la_matrix_from_float_buffer(UnsafePointer<Float>(OpaquePointer((valuer as NSData).bytes)), rows.unsignedValue, cols.unsignedValue, (stride ?? cols).unsignedValue, HINT, ATTR)
}
public func LaMatrice<Entier: Integer>(valuer: Data, rows: Entier, cols: Entier, stride: Entier? = nil, deallocator: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?) -> LaObjet {
	return la_matrix_from_float_buffer_nocopy(UnsafeMutablePointer<Float>(OpaquePointer((valuer as NSData).bytes)), rows.unsignedValue, cols.unsignedValue, (stride ?? cols).unsignedValue, HINT, deallocator, ATTR)
}
public func LaMatrice<Entier: Integer>(valuer: UnsafeRawPointer, rows: Entier, cols: Entier, stride: Entier? = nil) -> LaObjet {
	return la_matrix_from_float_buffer(UnsafePointer<Float>(OpaquePointer(valuer)), rows.unsignedValue, cols.unsignedValue, (stride ?? cols).unsignedValue, HINT, ATTR)
}
public func LaMatrice<Entier: Integer>(valuer: UnsafeRawPointer, rows: Entier, cols: Entier, stride: Entier? = nil, deallocator: (@convention(c) (UnsafeMutableRawPointer?) -> Void)?) -> LaObjet {
	return la_matrix_from_float_buffer_nocopy(UnsafeMutablePointer<Float>(OpaquePointer(valuer)), rows.unsignedValue, cols.unsignedValue, (stride ?? cols).unsignedValue, HINT, deallocator, ATTR)
}

private extension Integer {
    var signedValue: Int {
        switch self {
            case let value as Int: return value
            case let value as UInt: return Int(value)
            case let value as Int8: return Int(value)
            case let value as UInt8: return Int(value)
            case let value as Int16: return Int(value)
            case let value as UInt16: return Int(value)
            case let value as Int32: return Int(value)
            case let value as UInt32: return Int(value)
            case let value as Int64: return Int(value)
            case let value as UInt64: return Int(value)
            default: assertionFailure("\(type(of: self)) cannot be compatible")
        }
        return 0
    }
    var unsignedValue: UInt {
        switch self {
            case let value as Int: return UInt(value)
            case let value as UInt: return value
            case let value as Int8: return UInt(value)
            case let value as UInt8: return UInt(value)
            case let value as Int16: return UInt(value)
            case let value as UInt16: return UInt(value)
            case let value as Int32: return UInt(value)
            case let value as UInt32: return UInt(value)
            case let value as Int64: return UInt(value)
            case let value as UInt64: return UInt(value)
            default: assertionFailure("\(type(of: self)) cannot be compatible")
        }
        return 0
    }
}
