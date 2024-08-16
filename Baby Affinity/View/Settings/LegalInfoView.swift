//
//  LegalInfoView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

/// A view that displays legal information links (Privacy Policy and Terms of Service) and the app version.
struct LegalInfoView: View {
    
    // MARK: - Properties
    
    /// The app version text fetched from the app's info dictionary.
    private var appVersionText: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    /// URL for the Terms of Service document.
    private var termsServiceURL: URL {
        URL(string: "https://mikecenters.github.io/app/Baby-Affinity/documents/Terms-of-Service.pdf")!
    }
    
    /// URL for the Privacy Policy document.
    private var privacyPolicyURL: URL {
        URL(string: "https://mikecenters.github.io/app/Baby-Affinity/documents/Privacy-Policy.pdf")!
    }
    
    
    // MARK: - Body
    
    /// The body of the `LegalInfoView` that includes links to legal documents and the app version.
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                // Link to the Privacy Policy
                Link(destination: privacyPolicyURL) {
                    Text("Privacy Policy")
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Divider()
                
                // Link to the Terms of Service
                Link(destination: termsServiceURL) {
                    Text("Terms of Service")
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.caption).fontWeight(.semibold)
            
            // Display the app version
            Text("App Version: \(appVersionText ?? "<Missing App Version>")")
                .foregroundColor(.secondary)
                .font(.caption2)
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Legal Info View in List") {
    List {
        LegalInfoView()
    }
}

#endif
