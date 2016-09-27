//
//  Distribution.swift
//  C³
//
//  Created by Kota Nakano on 9/23/16.
//
//
import LaObjet
import Funktion
public protocol Distribution {
    func pdf(value: Buffer)
    func cdf(value: Buffer)
    func shuffle()
    var value: LaObjet { get }
}
