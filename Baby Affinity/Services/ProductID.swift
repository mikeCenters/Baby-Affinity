//
//  ProductID.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/28/24.
//

// MARK: - Product ID

/// An enumeration representing the various Product IDs for in-app purchases within the app.
///
/// The `ProductID` enumeration conforms to the `String`, `CaseIterable`, and `RawRepresentable` protocols.
/// Each case represents a specific in-app product, identified by its corresponding product ID string.
///
/// - Conforms to:
///   - `String`: Allows the raw value of each case to be a string, representing the product's ID.
///   - `CaseIterable`: Provides a collection of all the cases in the enumeration.
///   - `RawRepresentable`: Facilitates conversion between raw values (strings) and enum cases.
///
/// # Cases:
/// - `premiumAccount`: Represents the product ID for the premium account in the app (`com.mikeCenters.BabyAffinity.premium`).
enum ProductID: String, CaseIterable, RawRepresentable {
    /// The product ID for the premium account feature.
    case premiumAccount = "com.mikeCenters.BabyAffinity.premium"
}
