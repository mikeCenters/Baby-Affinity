//
//  SettingsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/12/24.
//

import SwiftUI

extension SettingsView {
    enum Item: Int, CaseIterable {
        case appCard
        case about, contact, products
        case resetData
        case legalInfo
        
        var label: String {
            switch self {
            case .appCard:
                "App Card"
            case .about:
                "About"
            case .contact:
                "Contact Us"
            case .products:
                "Products"
            case .resetData:
                "Reset Data"
            case .legalInfo:
                "Legal Info"
            }
        }
        
        var sectionID: Int {
            switch self {
            case .appCard:
                1
            case .about:
                2
            case .contact:
                2
            case .products:
                2
            case .resetData:
                3
            case .legalInfo:
                4
            }
        }
        
        var view: some View {
            Group {
                switch self {
                case .appCard:
                    AppCard()
                case .about:
                    NavigationLink {
                        AboutView()
                    } label: {
                        Text("About")
                    }
                case .contact:
                    Text("Contact Us")
                case .products:
                    Text("Products")
                case .resetData:
                    ResetDataButton()
                case .legalInfo:
                    LegalInfoView()
                }
            }
        }
        
        static func getLastSectionID() -> Int {
            var sectionCount: Int = 0
            for label in Item.allCases {
                if label.sectionID > sectionCount {
                    sectionCount = label.sectionID
                }
            }
            return sectionCount
        }
    }
}


struct SettingsView: View, NamePersistenceController_Admin {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) var modelContext
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                /// Iterate over each section
                ForEach(1...Item.getLastSectionID(), id: \.self) { sectionID in
                    Section {
                        /// Only display the items assigned to the sectionID.
                        ForEach(Item.allCases, id: \.self) { item in
                            if item.sectionID == sectionID {
                                item.view
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Settings View in Tab View") {
    TabView {
        SettingsView()
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

#Preview("Settings View") {
    SettingsView()
        .modelContainer(previewModelContainer)
}

#endif
