//
//  AboutView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

struct AboutView: View {
    
    private var wikiURL: URL {
        URL(string: "https://en.wikipedia.org/wiki/Elo_rating_system")!
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.title).bold()
                    
                    Text("Baby Affinity is a service that provides utilities related to assisting with determining baby names. The app utilizes an adaptation of the ELO Rating System, referred to as an Affinity Rating, to assist with finding a user's likeness to different names. While other services may be available, Baby Affinity is first in providing a professional rating system in making baby naming fun and exciting.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
            }
            
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Mission")
                        .font(.title).bold()
                    
                    Text("To provide robust utilities in relation to finding the perfect name for a new child.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
            }
            
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy")
                        .font(.title).bold()
                    
                    Text("To determine the Affinity Rating, this app collects data based upon the names you have selected and stores it locally on your device. At no time, is this data transmitted to any servers or devices through the means of this app. Unless otherwise annotated or approved via you, the user, this app collects no data. See the full privacy policy and terms of service for complete details.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
            }
            
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Affinity Rating")
                        .font(.title).bold()
                    
                    Text("The Affinity Rating System is an adaptation of the ELO Rating System. The ELO Rating System was invented by Arpad Elo and is used throughout many competetive environments to assess player skill levels. For more information on the ELO Rating System, visit the wiki link.")
                    
                    Link(destination: wikiURL, label: {
                        Text("Wikipedia: Elo Rating System")
                            .font(.callout)
                            .foregroundColor(.blue)
                    })
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
            }
        }
        .navigationTitle("Baby Affinity")
    }
}


#if DEBUG

// MARK: - Previews

#Preview("About View in a Tab View") {
    TabView {
        NavigationStack {
            AboutView()
        }
        .tabItem {
            Label {
                Text("Settings")
            } icon: {
                Image(systemName: "gearshape")
            }
        }
    }
    .modelContainer(previewModelContainer)
}

#Preview("About View") {
    NavigationStack {
        AboutView()
    }
}

#endif
