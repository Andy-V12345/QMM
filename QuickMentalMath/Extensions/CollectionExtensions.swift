//
//  CollectionExtensions.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/2/25.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
