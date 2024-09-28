//
//  SettingsNavigationStack.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/29/24.
//

import SwiftUI
import Store

// MARK: - Settings Navigation Stack

struct SettingsNavigationStack: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var store: Store
    
    
    // MARK: - Controls
    
    @Binding var isLoading: Bool
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    AppCard()
                }
                
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                    
                    NavigationLink {
                        ContactUsView()
                    } label: {
                        Label("Contact Us", systemImage: "paperplane.circle")
                    }
                    
                    NavigationLink {
                        ProductsView()
                    } label: {
                        Label("Products", systemImage: "cart.circle")
                    }
                }
                
                Section {
                    LastNameSetting()
                }
                
                Section {
                    restoreButton
                }
                
                Section {
                    ResetDataButton(beforeReset: { isLoading = true },
                                    afterReset: { isLoading = false })
                }
                
                Section {
                    LegalInfoView()
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    
    // MARK: - View Components
    
    private var restoreButton: some View {
        Button {
            Task {
                await store.restorePurchases()
            }
            
        } label: {
            Text("Restore Purchases")
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Settings Navigation Stack") {
    SettingsNavigationStack(isLoading: .constant(false))
        .environmentObject(Store.main)
}

#endif
