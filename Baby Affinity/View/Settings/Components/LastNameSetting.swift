//
//  LastNameSetting.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/3/24.
//

import SwiftUI

// MARK: - Last Name Setting

/// A view that provides a setting to update and store the user's last name in `AppStorage`.
/// The user's last name is filtered and validated before being stored.
struct LastNameSetting: View {
    
    // MARK: - Properties
    
    /// The last name, stored persistently using `AppStorage`.
    /// This allows the last name to be saved and automatically reloaded across app launches.
    @AppStorage("lastName") private var lastName = ""
    
    /// A state property used to manage the label of the text field.
    @State private var textFieldLabel = ""
    
    
    // MARK: - Controls
    
    /// A temporary state variable to hold the user input before it is validated and saved as the last name.
    @State private var temporaryName: String = ""
    
    /// A property that manages the focus state of the text field.
    @FocusState private var isFocused: Bool
    
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Label("Last Name", systemImage: "person.crop.circle")
            
            Spacer()
            
            TextField("Set here", text: $temporaryName) {
                // Once editing ends, filter and save the new last name
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


#if DEBUG

// MARK: - Previews

#Preview("Last Name Setting in a List") {
    List {
        LastNameSetting()
    }
}

#endif
