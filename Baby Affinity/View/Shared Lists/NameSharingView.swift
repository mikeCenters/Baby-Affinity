//
//  NameSharingView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 9/8/24.
//

import SwiftUI


// MARK: - Name Sharing View

struct NameSharingView: View, NamePersistenceController {
    
    // MARK: - Properties
    
    @Environment(\.modelContext) internal var modelContext
    @EnvironmentObject private var store: Store
    @StateObject private var nameSharingService: NameSharingService = .init()
    
    
    // MARK: - Controls and Constants
    
    @PremiumAccount private var isPremium
    @State private var isShowingReceivedNames: Bool = false
    @State private var isShowingProductPage: Bool = false
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            
            // Primary View
            
            PresentationLayout {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                        .foregroundColor(isPremium ? .green : .gray)
                    
                    Text("Share Names")
                        .font(.largeTitle).bold()
                    
                    Text("Share names with someone nearby and discover which names you both like.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Label {
                    Text("WiFi and Bluetooth must be enabled")
                    
                } icon: {
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                    .padding()
                    .background { Color(.secondarySystemBackground)}
                    .mask(RoundedRectangle(cornerRadius: 16))
            }
            
            
            // Broadcasting Animation
            
            if nameSharingService.sessionState != .connected && isPremium {
                VStack {
                    RadiatingSemiCircles()
                        .edgesIgnoringSafeArea(.top)
                        .offset(y: -100)
                    Spacer()
                }
            }
        }
        
        
        // MARK: - Sheet
        
        .sheet(isPresented: $isShowingReceivedNames) {
            let receivedNames = getNames()
            SharedNamesView(maleNames: receivedNames.0, femaleNames: receivedNames.1)
        }
        .sheet(isPresented: $isShowingProductPage) {
            ProductsView()
        }
        
        
        // MARK: - On Appear
        
        .onAppear {
            if isPremium {
                nameSharingService.startAdvertisingAndBrowsing()
            }
        }
        
        
        // MARK: - On Disappear
        
        .onDisappear {
            nameSharingService.stopAdvertisingAndBrowsing()
        }
        
        
        // MARK: - On Receive, On Change
        
        .onReceive(nameSharingService.$receivedNames.receive(on: DispatchQueue.main)) { receivedNames in
            guard let names = receivedNames, !names.isEmpty else {
                return
            }
            
            isShowingReceivedNames = true
        }
        
        .onReceive(nameSharingService.$sessionState.receive(on: DispatchQueue.main)) { sessionState in
            switch sessionState {
            case .connected:
                sendNames()
                
            default:
                break
            }
        }
        
        .onChange(of: isPremium) {
            if isPremium {
                isShowingProductPage = false
                nameSharingService.startAdvertisingAndBrowsing()
                
            } else {
                nameSharingService.stopAdvertisingAndBrowsing()
                isShowingProductPage = true
            }
        }
    }
}


// MARK: - Methods

extension NameSharingView: NamePersistenceController_Admin {
    
    /// Fetches a list of names and sends them using the `NameSharingService`.
    ///
    /// This method attempts to fetch names from the environment's `ModelContext` and, if successful,
    /// passes them to the `NameSharingService` for sharing. If the fetch operation fails, it logs an
    /// error message detailing the issue.
    ///
    /// - Note: The `NameSharingService` must be properly configured and initialized before this method is called.
    private func sendNames() {
        do {
            let fetchedNames = try fetchNames()
            nameSharingService.sendNames(fetchedNames)
            
        } catch {
            logError("Unable to fetch names to send in Name Sharing View: \(error.localizedDescription)")
        }
    }
    
    /// A method that retrieves and categorizes names received via the `nameSharingService`.
    ///
    /// This method fetches the names from the `nameSharingService` and then filters them based on gender.
    /// It separates the names into male and female categories. After filtering, it calls the
    /// `compareNames(maleNames:femaleNames:)` function to process and compare these lists, returning
    /// the results as tuples of `RankedMaleNames` and `RankedFemaleNames`.
    ///
    /// - Returns: A tuple containing two arrays:
    ///   - `RankedMaleNames`: An array of ranked male name: Tuples of a name and its rank in an array.
    ///   - `RankedFemaleNames`: An array of ranked female names: Tuples of a name and its rank in an array.
    ///
    /// - Note: If no names are received, the method will return two empty arrays.
    ///
    /// - SeeAlso: `compareNames(maleNames:femaleNames:)` for the processing and comparison of names.
    private func getNames() -> (RankedMaleNames, RankedFemaleNames) {
        guard let receivedNames = nameSharingService.receivedNames,
              !receivedNames.isEmpty
        else {
            return ([],[])
        }
        
        let maleNames = receivedNames.filter { $0.sex == .male }
        let femaleNames = receivedNames.filter { $0.sex == .female }
        
        return compareNames(maleNames: maleNames, femaleNames: femaleNames)
    }
}


#if DEBUG

// MARK: - Previews

#Preview("With Premium Account") {
    NameSharingView()
        .modelContainer(previewModelContainer)
        .environmentObject(Store.premium)
}

#Preview("With Non-Premium Account") {
    NameSharingView()
        .modelContainer(previewModelContainer)
        .environmentObject(Store.shared)
}

#endif
