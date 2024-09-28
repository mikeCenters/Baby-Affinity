//
//  AboutView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

// MARK: - About View

/// A view that provides information about the Baby Affinity app, including its purpose, mission, privacy policy, and the Affinity Rating system.
struct AboutView: View {
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            ForEach(Item.allCases, id: \.self) { item in
                SectionView(iconName: item.symbolName,
                            title: item.title,
                            description: item.bodyText) {
                    item.extendedContent
                }
            }
        }
        .navigationTitle("Baby Affinity")
    }
}


// MARK: - Items

extension AboutView {
    /// An enumeration representing the different sections available in the `AboutView`.
    enum Item: Int, CaseIterable {
        /// The URL for more information about the Elo Rating System.
        static private var wikiURL: URL {
            URL(string: "https://en.wikipedia.org/wiki/Elo_rating_system")!
        }
        
        // MARK: - Cases
        
        case about, mission, privacy, affinityRating
        
        
        // MARK: - Properties
        
        /**
         The name of the symbol to be used for the icon in each section.
         
         - Returns: A `String` representing the symbol name.
         */
        var symbolName: String {
            switch self {
            case .about:
                return "info.bubble"
            case .mission:
                return "medal"
            case .privacy:
                return "lock.shield"
            case .affinityRating:
                return "list.number"
            }
        }
        
        /**
         The title to be displayed for each section.
         
         - Returns: A `String` representing the title.
         */
        var title: String {
            switch self {
            case .about:
                return "About"
            case .mission:
                return "Mission"
            case .privacy:
                return "Privacy"
            case .affinityRating:
                return "Affinity Rating"
            }
        }
        
        /**
         The descriptive text to be displayed for each section.
         
         - Returns: A `String` representing the body text.
         */
        var bodyText: String {
            switch self {
            case .about:
                return "Baby Affinity is a service that provides utilities related to assisting with determining baby names. The app utilizes an adaptation of the ELO Rating System, referred to as an Affinity Rating, to assist with finding a user's likeness to different names. While other services may be available, Baby Affinity is first in providing a professional rating system in making baby naming fun and exciting."
            case .mission:
                return "To provide robust utilities in relation to finding the perfect name for a new child."
            case .privacy:
                return "To determine the Affinity Rating, this app collects data based upon the names you have selected and stores it locally on your device. At no time, is this data transmitted to any servers or devices through the means of this app. Unless otherwise annotated or approved via you, the user, this app collects no data. See the full privacy policy and terms of service for complete details."
            case .affinityRating:
                return "The Affinity Rating System is an adaptation of the ELO Rating System. The ELO Rating System was invented by Arpad Elo and is used throughout many competitive environments to assess player skill levels. For more information on the ELO Rating System, visit the wiki link."
            }
        }
        
        /**
         The extended content view to be displayed for each section.
         
         - Returns: A `View` representing the extended content.
         */
        var extendedContent: some View {
            Group {
                switch self {
                case .about:
                    EmptyView()
                case .mission:
                    EmptyView()
                case .privacy:
                    EmptyView()
                case .affinityRating:
                    HStack {
                        Spacer()
                        Link(destination: AboutView.Item.wikiURL, label: {
                            Text("Wikipedia: Elo Rating System")
                                .font(.callout)
                                .foregroundStyle(.tint)
                        })
                        Spacer()
                    }
                }
            }
        }
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
