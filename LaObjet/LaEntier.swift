//
//  LaEntier.swift
//  macOS
//
//  Created by Kota on 9/30/16.
//
//

internal extension Integer {
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
