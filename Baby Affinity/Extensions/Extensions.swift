//
//  Extensions.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/5/24.
//

import Foundation
import SwiftUI
import Store

// MARK: - View

extension View {
    /// Loads products in the specified store.
    ///
    /// This function initiates a task to fetch products using the given store and the specified product IDs.
    /// If no product IDs are provided, it defaults to loading all available product IDs from the `ProductID` enum.
    ///
    /// - Parameters:
    ///   - store: The store instance that conforms to `ObservableObject` and is responsible for fetching products.
    ///   - productIDs: A set of product IDs to fetch. Defaults to all product IDs from `ProductID.allCases`.
    ///
    /// - Returns: A view that can perform tasks, with the product loading operation scheduled.
    func loadProducts(in store: Store, productIDs: Set<String> = .init(ProductID.allCases.map(\.rawValue))) -> some View {
        self
            .task {
                await store.fetchProducts(productIDs)
            }
    }
}


// MARK: - Array

extension Array {
    /// Generates an array of random indices.
    ///
    /// - Parameters:
    ///   - count: The number of random indices to generate.
    /// - Returns: An array of random integers within the range `0..<upperLimit`.
    ///
    /// - Note: This method is private and intended to be used internally for generating random indices within the array.
    private func generateRandomIndices(count: Int) -> Set<Int> {
        var indices = Set<Int>()
        while indices.count < count {
            let randomIndex = Int.random(in: 0..<self.count)
            indices.insert(randomIndex)
        }
        return indices
    }
    
    
    /// Returns an array of random elements from the array.
    ///
    /// - Parameter count: The number of random elements to return. If `count` is greater than the number of elements in the array, all elements are returned in a random order.
    /// - Returns: An array containing `count` random elements from the array.
    func randomElements(count: Int) -> [Element] {
        guard !isEmpty else { return [] }
        let limitedCount = Swift.min(count, self.count)
        
        let randomIndices = generateRandomIndices(count: limitedCount)
        return randomIndices.sorted().compactMap { self.indices.contains($0) ? self[$0] : nil }
    }
}


// MARK: - Decimal

extension Decimal {
    /// Converts a Decimal to an Int, rounding the value.
    /// 
    /// - Parameter roundBehavior: The rounding behavior to use. If `nil`, the default rounding behavior is used.
    /// - Returns: The converted Int value.
    func convertToInt(roundBehavior: NSDecimalNumberBehaviors? = nil) -> Int {
        let nsDecimalNumber = NSDecimalNumber(decimal: self)
        return nsDecimalNumber.rounding(accordingToBehavior: roundBehavior).intValue
    }
}


// MARK: - Image

extension Image {
    /// Applies a common style to the image, including resizing, scaling, framing, and setting symbol rendering mode and foreground color.
    ///
    /// This modifier is intended for images used in header or similar sections where a consistent style is desired.
    ///
    /// - Returns: A view that applies the specified style to the image.
    func headerSymbolStyle() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: 64, height: 64)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.primary, .tint)
    }
}
