//
//  Store.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/3/24.
//

import Foundation
import StoreKit
import SwiftUI

typealias Transaction = StoreKit.Transaction

@MainActor
final class Store: ObservableObject {
    static let premiumProductID = "com.mikeCenters.BabyAffinity.premium"
    
    static let shared = Store()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    private init() {
        Task {
            await syncPurchasedProducts()
            monitorTransactionUpdates()
        }
    }
    
    func fetchProducts() async {
        let productIDs: Set<String> = ["com.mikeCenters.BabyAffinity.premium"]
        
        do {
            products = try await Product.products(for: productIDs)
            
        } catch {
            logError("Failed to fetch products: \(error.localizedDescription)")
        }
    }
    
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
    
    private func syncPurchasedProducts() async {
        purchasedProductIDs = []
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                purchasedProductIDs.insert(transaction.productID)
                
            case .unverified(_, let error):
                logError("Unverified transaction during sync: \(error.localizedDescription)")
            }
        }
    }
    
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
    
    private func handleTransaction(_ transaction: Transaction) async {
        purchasedProductIDs.insert(transaction.productID)
        await transaction.finish()
    }
}
