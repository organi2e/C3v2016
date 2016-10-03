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
	
	static var matriceType: la_scalar_type_t { get }
	
	static var matriceNormé: (la_object_t, la_norm_t) -> Élément { get }
	
	static var matriceSplat: (Élément, la_attribute_t) -> la_object_t { get }
	static var matriceÉchelle: (la_object_t, Élément) -> la_object_t { get }
	static var matriceCopy: (UnsafePointer<Élément>, la_count_t, la_count_t, la_count_t, la_hint_t, la_attribute_t) -> la_object_t { get }
	static var matriceNocopy: (UnsafeMutablePointer<Élément>, la_count_t, la_count_t, la_count_t, la_hint_t, la_deallocator_t?, la_attribute_t) -> la_object_t { get }
	static var matriceBytes: (UnsafeMutablePointer<Élément>, la_count_t, la_object_t) -> la_status_t { get }
	
	static var vecteurSin: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vecteurCos: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vecteurTanh: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vecteurAtan: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vecteurExp: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vecteurLog: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vecteurRec: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
	static var vecteurRsqrt: (UnsafeMutablePointer<Élément>, UnsafePointer<Élément>, UnsafePointer<Int32>) -> Void { get }
}
public protocol LaSoloType {}
extension Float: LaType, LaSoloType {
	public static var matriceType: la_scalar_type_t {
		return la_scalar_type_t(LA_SCALAR_TYPE_FLOAT)
	}
	public static var matriceSplat: (Float, la_attribute_t) -> la_object_t {
		return la_splat_from_float
	}
	public static var matriceNormé: (la_object_t, la_norm_t) -> Float {
		return la_norm_as_float
	}
	public static var matriceCopy: (UnsafePointer<Float>, la_count_t, la_count_t, la_count_t, la_hint_t, la_attribute_t) -> la_object_t {
		return la_matrix_from_float_buffer
	}
	public static var matriceNocopy: (UnsafeMutablePointer<Float>, la_count_t, la_count_t, la_count_t, la_hint_t, la_deallocator_t?, la_attribute_t) -> la_object_t {
		return la_matrix_from_float_buffer_nocopy
	}
	public static var matriceBytes: (UnsafeMutablePointer<Float>, la_count_t, la_object_t) -> la_status_t {
		return la_matrix_to_float_buffer
	}
	public static var matriceÉchelle: (la_object_t, Float) -> la_object_t {
		return la_scale_with_float
	}
	public static var vecteurSin: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvsinf
	}
	public static var vecteurCos: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvcosf
	}
	public static var vecteurTanh: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvtanhf
	}
	public static var vecteurAtan: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvatanf
	}
	public static var vecteurExp: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvexpf
	}
	public static var vecteurLog: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvlogf
	}
	public static var vecteurRec: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvrecf
	}
	public static var vecteurRsqrt: (UnsafeMutablePointer<Float>, UnsafePointer<Float>, UnsafePointer<Int32>) -> Void {
		return vvsqrtf
	}
}
public protocol LaDoubléType {}
extension Double: LaType, LaDoubléType {
	public static var matriceType: la_scalar_type_t {
		return la_scalar_type_t(LA_SCALAR_TYPE_DOUBLE)
	}
	public static var matriceSplat: (Double, la_attribute_t) -> la_object_t {
		return la_splat_from_double
	}
	public static var matriceNormé: (la_object_t, la_norm_t) -> Double {
		return la_norm_as_double
	}
	public static var matriceCopy: (UnsafePointer<Double>, la_count_t, la_count_t, la_count_t, la_hint_t, la_attribute_t) -> la_object_t {
		return la_matrix_from_double_buffer
	}
	public static var matriceNocopy: (UnsafeMutablePointer<Double>, la_count_t, la_count_t, la_count_t, la_hint_t, la_deallocator_t?, la_attribute_t) -> la_object_t {
		return la_matrix_from_double_buffer_nocopy
	}
	public static var matriceBytes: (UnsafeMutablePointer<Double>, la_count_t, la_object_t) -> la_status_t {
		return la_matrix_to_double_buffer
	}
	public static var matriceÉchelle: (la_object_t, Double) -> la_object_t {
		return la_scale_with_double
	}
	public static var vecteurSin: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvsin
	}
	public static var vecteurCos: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvcos
	}
	public static var vecteurTanh: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvtanh
	}
	public static var vecteurAtan: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvatan
	}
	public static var vecteurExp: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvexp
	}
	public static var vecteurLog: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvlog
	}
	public static var vecteurRec: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvrec
	}
	public static var vecteurRsqrt: (UnsafeMutablePointer<Double>, UnsafePointer<Double>, UnsafePointer<Int32>) -> Void {
		return vvsqrt
	}
}
