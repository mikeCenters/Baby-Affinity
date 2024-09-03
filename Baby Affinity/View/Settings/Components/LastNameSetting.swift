//
//  LastNameSetting.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/3/24.
//

import SwiftUI

struct LastNameSetting: View {
    
    // MARK: - Properties
    
    /// The last name, stored in `AppStorage`.
    @AppStorage("lastName") private var lastName = ""
    
    @State private var textFieldLabel = ""
    
    // MARK: - Controls
    
    @State private var temporaryName: String = ""
    
    @FocusState private var isFocused: Bool
    
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            HStack {
                Text("Last Name")
                
                Spacer()
                
                TextField("Set here", text: $temporaryName) {
                    lastName = Name.filter(temporaryName)
                }
                .multilineTextAlignment(.trailing)
                .keyboardType(.alphabet)
                .focused($isFocused)
                .foregroundStyle(isFocused ? .primary : .secondary)
                // MARK: - On Appear
                .onAppear {
                    temporaryName = lastName
                }
                // MARK: - On Change
                .onChange(of: temporaryName) { oldValue, newValue in
                    temporaryName = Name.filter(newValue)
                }
            }
        }
    }
}


// MARK: - Previews

#Preview("Last Name Setting in a List") {
    List {
        LastNameSetting()
    }
}
