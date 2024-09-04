//
//  Store.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/3/24.
//

import Foundation
import StoreKit
import StoreKit

@MainActor
final class Store: ObservableObject {
    
    // MARK: - Instances
    
    static let shared = Store()
    
    
    // MARK: - Properties
    
    @Published var products: [Product] = []
    
    
    // MARK: - Controls and Constants
    
    private var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    
    // MARK: - Init
    
    private init() {
        Task {
            await fetchProducts()
            monitorTransactionUpdates()
        }
    }
    
    
    // MARK: - Methods
    
    func fetchProducts() async {
        let productIDs: Set<String> = ["com.mikeCenters.BabyAffinity.premium"]
        
        do {
            products = try await Product.products(for: productIDs)
            
        } catch {
            logError("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    
                case .unverified(_, let error):
                    logError("Unverified transaction: \(error)")
                }
            case .pending:
                break
            case .userCancelled:
                break
            @unknown default:
                break
            }
            
        } catch {
            logError("Purchase failed: \(error)")
        }
    }
    
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // Handle restored purchases
                await transaction.finish()
                
            case .unverified(_, let error):
                // Handle error
                logError("Unverified transaction: \(error)")
            }
        }
    }
    
    private func monitorTransactionUpdates() {
        Task {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    // Handle successful transaction
                    await transaction.finish()
                    
                case .unverified(_, let error):
                    // Handle error
                    logError("Unverified transaction: \(error)")
                }
            }
        }
    }
}
