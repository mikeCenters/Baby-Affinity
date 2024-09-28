//
//  LegalInfoView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

// MARK: - Legal Info View

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
    
    
    // MARK: - Controls
    
    /// The property used to display the app version text.
    var showAppVersion = true
        
    
    // MARK: - Body
    
    /// The body of the `LegalInfoView` that includes links to legal documents and the app version.
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                // Link to the Privacy Policy
                Link("Privacy Policy", destination: privacyPolicyURL)
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Divider()
                
                // Link to the Terms of Service
                Link("Terms of Service", destination: termsServiceURL)
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: UIFont.preferredFont(forTextStyle: .caption1).lineHeight + 4)
            .font(.caption).fontWeight(.semibold)
            
            
            if showAppVersion {
                // Display the app version
                Text("App Version: \(appVersionText ?? "<Missing App Version>")")
                    .foregroundColor(.secondary)
                    .font(.caption2)
            }
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Legal Info View in List") {
    List {
        Section("With App Version") {
            LegalInfoView()
        }
        
        Section("Without App Version") {
            LegalInfoView(showAppVersion: false)
        }
    }
}

#Preview("Legal Info View in Footer") {
    VStack(spacing: 0) {
        List {
            ForEach(1..<10) { i in
                Text("Some Background Data")
            }
        }
        
        LegalInfoView()
            .frame(height: 44)
            .padding()
    }
}

#endif
