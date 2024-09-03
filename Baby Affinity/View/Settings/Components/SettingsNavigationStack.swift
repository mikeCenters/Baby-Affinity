//
//  SettingsNavigationStack.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/29/24.
//

import SwiftUI


struct SettingsNavigationStack: View {
    
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
                        Text("About")
                    }
                    
                    NavigationLink {
                        ContactUsView()
                    } label: {
                        Text("Contact Us")
                    }
                    
                    NavigationLink {
                        Text("Products View")
                    } label: {
                        Text("Products")
                    }
                }
                
                Section {
                    LastNameSetting()
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
}

#if DEBUG

// MARK: - Previews

#Preview {
    SettingsNavigationStack(isLoading: .constant(false))
}

#endif
