//
//  Baby_AffinityApp.swift
//  Baby Affinity
//
//  Created by Mike Centers on 7/17/24.
//

import SwiftUI
import SwiftData
import Store

@main
struct Baby_AffinityApp: App {
    
    // MARK: - Properties
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Name.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var store = Store.main
    
    @AppStorage("isShowingOnboarding") var isShowingOnboarding: Bool = true
    
    
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
