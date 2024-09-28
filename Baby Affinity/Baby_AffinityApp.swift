//
//  Baby_AffinityApp.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import SwiftUI
import SwiftData
import Store
import SystemLogger

@main
struct Baby_AffinityApp: App {
    
    // MARK: - Properties
    
    /// The shared model container used for managing data persistence throughout the app.
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Name.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
            
        } catch {
            SystemLogger.main.logCritical("Could not create ModelContainer: \(error.localizedDescription)")
            fatalError("Could not create ModelContainer: \(error.localizedDescription)")
        }
    }()
    
    /// The shared store instance for managing in-app purchases and product data.
    @StateObject private var store = Store.main
    
    /// A boolean flag indicating whether the onboarding view should be shown to the user.
    @AppStorage("isShowingOnboarding") private var isShowingOnboarding: Bool = true
    
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            if isShowingOnboarding {
                OnboardingView(isShown: $isShowingOnboarding)
                
            } else {
                ContentView()
                    .task {
                        let productIDs = Set<String>(ProductID.allCases.map(\.rawValue))
                        await store.fetchProducts(productIDs)
                    }
            }
        }
        .environmentObject(store)
        .modelContainer(sharedModelContainer)
    }
}
