//
//  ContactUsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI
import MessageUI

// MARK: - Contact Us View

/**
 A view that provides users with options to contact support, submit feature requests, and provide feedback.

 The view includes buttons that, when tapped, open a mail compose view pre-filled with relevant details for each contact option.
 */
struct ContactUsView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Image(systemName: "person.fill.questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.primary, .tint)
                Spacer()
            }
            
            ScrollView {
                ForEach(Item.allCases, id: \.self) { item in
                    SectionView(iconName: item.symbolName,
                                title: item.title,
                                description: item.bodyText) {
                        item.extendedContent
                    }
                }
            }
        }
        .navigationTitle("Support")
    }
}


// MARK: - Items

extension ContactUsView {
    /**
     An enumeration representing the different types of contact options available in the `ContactUsView`.

     - needHelp: Represents the option to contact support for assistance.
     - featureRequest: Represents the option to submit a feature request.
     - feedback: Represents the option to provide feedback about the app.
     */
    enum Item: Int, CaseIterable {
        case needHelp, featureRequest, feedback
        
        /**
         The name of the symbol to be used for the icon representing each contact option.
         
         - Returns: A `String` representing the symbol name.
         */
        var symbolName: String {
            switch self {
            case .needHelp:
                return "questionmark.bubble"
            case .featureRequest:
                return "lightbulb.max"
            case .feedback:
                return "note.text.badge.plus"
            }
        }
        
        /**
         The title to be displayed for each contact option.
         
         - Returns: A `String` representing the title.
         */
        var title: String {
            switch self {
            case .needHelp:
                return "Need Help?"
            case .featureRequest:
                return "Feature Request"
            case .feedback:
                return "Feedback"
            }
        }
        
        /**
         The descriptive text to be displayed for each contact option.
         
         - Returns: A `String` representing the body text.
         */
        var bodyText: String {
            switch self {
            case .needHelp:
                return "Contact support for any issues regarding the use of this app."
            case .featureRequest:
                return "Help drive the direction of Baby Affinity by submitting a feature request."
            case .feedback:
                return "While the Baby Affinity app is tested heavily prior to release, errors with any app are possible. Let us know what we got right and wrong."
            }
        }
        
        /**
         The extended content view to be displayed for each contact option.
         
         - Returns: A `View` representing the extended content.
         */
        var extendedContent: some View {
            Group {
                switch self {
                case .needHelp:
                    HStack {
                        Spacer()
                        SendEmailButton(emailRecipients: ["support.babyaffinity@icloud.com"],
                                        emailSubject: "Support: ",
                                        buttonText: "Contact Support")
                        Spacer()
                    }
                    
                case .featureRequest:
                    HStack {
                        Spacer()
                        SendEmailButton(emailRecipients: ["request.babyaffinity@icloud.com"],
                                        emailSubject: "Feature Request: ",
                                        buttonText: "Request Feature")
                        Spacer()
                    }
                    
                case .feedback:
                    HStack {
                        Spacer()
                        SendEmailButton(emailRecipients: ["feedback.babyaffinity@icloud.com"],
                                        emailSubject: "Feedback: ",
                                        buttonText: "Issue Feedback")
                        Spacer()
                    }
                }
            }
        }
    }
}

#if DEBUG

// MARK: - Previews

/**
 Provides previews for `ContactUsView` within a TabView and a NavigationStack.
 */
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

/**
 Provides a preview for `ContactUsView` within a NavigationStack.
 */
#Preview("Contact Us View") {
    NavigationStack {
        ContactUsView()
    }
}

#endif
