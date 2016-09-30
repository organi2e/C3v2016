//
//  LaÉlément.swift
//  C³
//
//  Created by Kota on 9/30/16.
//
//

import Accelerate

public protocol LaType: FloatingPoint {
	associatedtype Élément: FloatingPoint
	static var type: la_scalar_type_t { get }
	static var splat: (Élément, la_attribute_t) -> la_object_t { get }
	static var norm: (la_object_t, la_norm_t) -> Élément { get }
	static var copy: (UnsafePointer<Élément>, la_count_t, la_count_t, la_count_t, la_hint_t, la_attribute_t) -> la_object_t { get }
	static var nocopy: (UnsafeMutablePointer<Élément>, la_count_t, la_count_t, la_count_t, la_hint_t, la_deallocator_t?, la_attribute_t) -> la_object_t { get }
	static var bytes: (UnsafeMutablePointer<Élément>, la_count_t, la_object_t) -> la_status_t { get }
	static var scale: (la_object_t, Élément) -> la_object_t { get }
	static var vSin: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vCos: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vTanh: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vAtan: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vExp: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vLog: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vRec: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vRsqrt: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
}
public protocol LaSoloType {}
extension Float: LaType, LaSoloType {
	public var Z: Int { return 0 }
	public static var type: la_scalar_type_t { return la_scalar_type_t(LA_SCALAR_TYPE_FLOAT) }
	public static var splat: (Float, la_attribute_t) -> la_object_t {
		return la_splat_from_float
	}
	public static var norm: (la_object_t, la_norm_t) -> Float {
		return la_norm_as_float
	}
	public static var copy: (UnsafePointer<Float>, la_count_t, la_count_t, la_count_t, la_hint_t, la_attribute_t) -> la_object_t {
		return la_matrix_from_float_buffer
	}
	public static var nocopy: (UnsafeMutablePointer<Float>, la_count_t, la_count_t, la_count_t, la_hint_t, la_deallocator_t?, la_attribute_t) -> la_object_t {
		return la_matrix_from_float_buffer_nocopy
	}
	public static var bytes: (UnsafeMutablePointer<Float>, la_count_t, la_object_t) -> la_status_t {
		return la_matrix_to_float_buffer
	}
	public static var scale: (la_object_t, Float) -> la_object_t {
		return la_scale_with_float
	}
	public static var vSin: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvsinf
	}
	public static var vCos: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvcosf
	}
	public static var vTanh: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvtanhf
	}
	public static var vAtan: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvatanf
	}
	public static var vExp: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvexpf
	}
	public static var vLog: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvlogf
	}
	public static var vRec: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvrecf
	}
	public static var vRsqrt: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvsqrtf
	}
}
public protocol LaDoubléType {}
extension Double: LaType, LaDoubléType {
	public static var type: la_scalar_type_t { return la_scalar_type_t(LA_SCALAR_TYPE_DOUBLE) }
	public static var splat: (Double, la_attribute_t) -> la_object_t {
		return la_splat_from_double
	}
	public static var norm: (la_object_t, la_norm_t) -> Double {
		return la_norm_as_double
	}
	public static var copy: (UnsafePointer<Double>, la_count_t, la_count_t, la_count_t, la_hint_t, la_attribute_t) -> la_object_t {
		return la_matrix_from_double_buffer
	}
	public static var nocopy: (UnsafeMutablePointer<Double>, la_count_t, la_count_t, la_count_t, la_hint_t, la_deallocator_t?, la_attribute_t) -> la_object_t {
		return la_matrix_from_double_buffer_nocopy
	}
	public static var bytes: (UnsafeMutablePointer<Double>, la_count_t, la_object_t) -> la_status_t {
		return la_matrix_to_double_buffer
	}
	public static var scale: (la_object_t, Double) -> la_object_t {
		return la_scale_with_double
	}
	public static var vSin: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvsin
	}
	public static var vCos: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvcos
	}
	public static var vTanh: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvtanh
	}
	public static var vAtan: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvatan
	}
	public static var vExp: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvexp
	}
	public static var vLog: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvlog
	}
	public static var vRec: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvrec
	}
	public static var vRsqrt: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvsqrt
	}
}
