//
//  ContactUsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI

struct ContactUsView: View {
    var body: some View {
        Text("Hello, World!")
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Contact Us View in a Tab View") {
    TabView {
        NavigationStack {
            ContactUsView()
        }
        .tabItem {
            Label {
                Text("Settings")
            } icon: {
                Image(systemName: "gearshape")
            }
        }
    }
}

#Preview("Contact Us View") {
    NavigationStack {
        AboutView()
    }
}

#endif
