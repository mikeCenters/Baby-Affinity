//
//  Store.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/3/24.
//

import Foundation
import StoreKit
import SwiftUI
import Combine

typealias Transaction = StoreKit.Transaction


// MARK: - Premium Account Wrapper

/**
 A property wrapper that tracks whether the user has a Premium account.
 
 This wrapper monitors the `Store` environment object to check if the user has purchased the premium account. It automatically updates its internal state based on the `purchasedProductIDs` in the `Store`. Manual updates to this wrapper are prevented.
 
 Usage:
 ```swift
 @PremiumAccount private var isPremium: Bool
 ```
 The wrappedValue provides read-only access to the premium status, while the projectedValue provides a binding to isPremium, but without allowing external modification.
 
 - Important: This property wrapper should not be manually set outside of its intended use. An attempt to do so will log an error.
 - Important: This property wrapper uses the `Store` within the environment to manage state changes.
 */
@propertyWrapper
struct PremiumAccount: DynamicProperty {
    /// The store witihn the environment.
    @EnvironmentObject private var store: Store
    @State private var isPremium: Bool = false
    
    var wrappedValue: Bool {
        isPremium
    }
    
    var projectedValue: Binding<Bool> {
        Binding(
            get: { self.isPremium },
            set: { _ in
                // Prevent manual updates
                logError("The Premium Account property wrapper should not be manually set.")
            }
        )
    }
    
    func update() {
        Task { @MainActor in
            isPremium = store.purchasedProductIDs.contains(Store.premiumProductID)
        }
    }
}


// MARK: - Store
/**
 A singleton class that manages interactions with the App Store, including product fetching, purchasing, and restoring purchases.
 
 The `Store` class is responsible for maintaining the state of purchased products, handling purchase transactions, and synchronizing entitlements. It provides methods to fetch available products, initiate purchases, and restore previous purchases. It also handles transaction updates and maintains the state of the premium product.
 
 Usage:
 ```swift
 Store.shared.fetchProducts()
 Store.shared.purchase(product)
 Store.shared.restorePurchases()
 ```
 - Note: The class is annotated with @MainActor to ensure that all its methods are run on the main thread.
 - Important: The class has a debugging instance `Store.premium` for use within debugging that unlocks all content.

 Properties
 - products: A published array of Product objects available for purchase.
 - purchasedProductIDs: A published set of product IDs representing the user’s purchased products.
 
 Initialization
 
 The Store class is initialized with an optional isPremium parameter for debugging purposes, allowing the content to be unlocked during development. The shared static property provides a singleton instance of the Store.
 
 Methods
 - fetchProducts(): Asynchronously fetches the available products from the App Store.
 - purchase(_:): Asynchronously handles the purchase process for a given product.
 - restorePurchases(): Asynchronously restores previously purchased products.
 - monitorTransactionUpdates(): Monitors and handles updates to transactions, including purchases and refunds.
 - syncPurchasedProducts(): Synchronizes the list of purchased products based on current entitlements.
 - handlePurchaseVerification(_:): Handles the verification of a purchase transaction.
 - handleTransaction(_:): Processes a transaction, updating the list of purchased product IDs and finishing the transaction.
 
 Debugging Methods
 - unlockContent(): Adds the premium product ID to the set of purchased product IDs for debugging purposes.
 */
@MainActor
final class Store: ObservableObject {
    
    // MARK: - Class Properties
    
    static let premiumProductID = "com.mikeCenters.BabyAffinity.premium"
    
    
    // MARK: - Instances
    /// The shared instance of the `Store` class.
    static let shared = Store()
    
    
    #if DEBUG
    
    /// The debugging instance of the `Store` class. All content is unlocked.
    static let premium = Store(isPremium: true)
    
    #endif
    
    
    // MARK: - Properties
    
    /// A published array of `Product` objects available for purchase.
    @Published var products: [Product] = []
    
    /// A published set of product IDs representing the user's purchased products.
    @Published var purchasedProductIDs: Set<String> = []
    
    
    // MARK: - Init
    
    /// Initializes the `Store` with an optional `isPremium` parameter for debugging purposes.
    private init(isPremium: Bool = false) {
        Task {
            await syncPurchasedProducts()
            monitorTransactionUpdates()
            
            #if DEBUG
            
            if isPremium {
                unlockContent()
            }
            
            #endif
        }
    }
    
    
    // MARK: - Methods
    
    /**
     Asynchronously fetches the available products from the App Store.
     
     This method updates the `products` array with the fetched `Product` objects.
     
     - Note: Call this method to refresh the list of available products.
     */
    func fetchProducts() async {
        let productIDs: Set<String> = ["com.mikeCenters.BabyAffinity.premium"]
        
        do {
            products = try await Product.products(for: productIDs)
            
        } catch {
            logError("Failed to fetch products: \(error.localizedDescription)")
        }
    }
    
    /**
     Asynchronously handles the purchase process for a given product.
     
     - Parameter product: The `Product` to be purchased.
     - Throws: An error if the purchase fails.
     */
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                handlePurchaseVerification(verification)
                
            case .pending, .userCancelled:
                break
                
            @unknown default:
                break
            }
            
        } catch {
            logError("Purchase failed: \(error.localizedDescription)")
        }
    }
    
    /**
     Asynchronously restores previously purchased products.
     
     This method updates the `purchasedProductIDs` set with any previously purchased products that are found.
     */
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                await handleTransaction(transaction)
                
            case .unverified(_, let error):
                logError("Unverified transaction during restore: \(error.localizedDescription)")
            }
        }
    }
    
    /**
     Monitors and handles updates to transactions, including purchases and refunds.
     
     This method is continuously listening for transaction updates and processes them as they occur.
     */
    private func monitorTransactionUpdates() {
        Task {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await handleTransaction(transaction)
                    
                case .unverified(_, let error):
                    logError("Unverified transaction update: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /**
     Synchronizes the list of purchased products based on current entitlements.
     
     This method updates the `purchasedProductIDs` set with the product IDs of the currently verified entitlements.
     */
    private func syncPurchasedProducts() async {
        purchasedProductIDs = []
        for await result in Transaction.currentEntitlements {
            switch result {
                
            case .verified(let transaction):
                await handleTransaction(transaction)
                
            case .unverified(_, let error):
                logError("Unverified transaction during sync: \(error.localizedDescription)")
            }
        }
    }
    
    /**
     Handles the verification of a purchase transaction.
     
     - Parameter verification: The `VerificationResult` of the purchase transaction.
     */
    private func handlePurchaseVerification(_ verification: VerificationResult<Transaction>) {
        switch verification {
        case .verified(let transaction):
            Task {
                await handleTransaction(transaction)
            }
        case .unverified(_, let error):
            logError("Unverified transaction: \(error.localizedDescription)")
        }
    }
    
    /**
     Processes a transaction, updating the list of purchased product IDs and finishing the transaction.
     
     - Parameter transaction: The `Transaction` to be processed.
     */
    private func handleTransaction(_ transaction: Transaction) async {
        if let revocationDate = transaction.revocationDate, revocationDate < Date() {
            purchasedProductIDs.remove(transaction.productID)
            
        } else {
            purchasedProductIDs.insert(transaction.productID)
        }
        
        await transaction.finish()
    }
    
    
    #if DEBUG
    
    // MARK: - Debugging Methods
    
    /// Adds the premium product ID to the set of purchased product IDs for debugging purposes.
    private func unlockContent() {
        purchasedProductIDs.insert(Store.premiumProductID)
    }
    
    #endif
}
