//
//  ContactUsView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI
import MessageUI

/**
 A view that provides users with options to contact support, submit feature requests, and provide feedback.

 The view includes buttons that, when tapped, open a mail compose view pre-filled with relevant details for each contact option.
 */
struct ContactUsView: View {
    
    // MARK: - Properties
    
    /// The selected sex for which the names are filtered, stored in `AppStorage`.
    @AppStorage("selectedSex") private var selectedSex = Sex.male
    
    
    // MARK: Controls and Constants
    
    /// A Boolean value that indicates whether the device can send emails.
    private var canSendEmails: Bool { MFMailComposeViewController.canSendMail() }
    /// A state variable that controls the presentation of the mail compose view.
    @State private var isShowingMailView: Bool = false
    /// An array of email recipient addresses.
    @State private var emailRecipients: [String] = []
    /// The subject of the email.
    @State private var emailSubject: String = ""
    /// The body template of the email, including app version details.
    @State private var emailBodyTemplate: String =
        """
        \n\n
        =============
        App Version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unable to get App Version.")
        =============
        """
    
    
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
            .padding(.bottom)
            
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer()
                            Image(systemName: "questionmark.bubble")
                                .headerSymbolStyle()
                            Spacer()
                        }
                        
                        Text("Need Help?")
                            .font(.title).bold()
                        
                        Text("Contact support for any issues regarding the use of this app.")
                        
                        HStack {
                            Spacer()
                            Button {
                                isShowingMailView.toggle()
                                emailRecipients = ["support.babyaffinity@icloud.com"]
                                emailSubject = "Support: "
                            } label: {
                                Text("Contact Support")
                                    .bold()
                            }
                            .buttonStyle(.borderedProminent)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    Divider()
                }
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer()
                            Image(systemName: "lightbulb.max")
                                .headerSymbolStyle()
                            Spacer()
                        }
                        
                        Text("Feature Request")
                            .font(.title).bold()
                        
                        Text("Help drive the direction of Baby Affinity by submitting a feature request.")
                        
                        HStack {
                            Spacer()
                            Button {
                                isShowingMailView.toggle()
                                emailRecipients = ["request.babyaffinity@icloud.com"]
                                emailSubject = "Feature Request: "
                            } label: {
                                Text("Request Feature")
                                    .bold()
                            }
                            .buttonStyle(.borderedProminent)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    Divider()
                }
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer()
                            Image(systemName: "note.text.badge.plus")
                                .headerSymbolStyle()
                            Spacer()
                        }
                        
                        Text("Feedback")
                            .font(.title).bold()
                        
                        Text("While the Baby Affinity app is tested heavily prior to release, errors with any app are possible. Let us know what we got right and wrong.")
                        
                        HStack {
                            Spacer()
                            Button {
                                isShowingMailView.toggle()
                                emailRecipients = ["feedback.babyaffinity@icloud.com"]
                                emailSubject = "Feedback: "
                            } label: {
                                Text("Issue Feedback")
                                    .bold()
                            }
                            .buttonStyle(.borderedProminent)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    Divider()
                }
            }
        }
        .navigationTitle("Support")
        .sheet(isPresented: $isShowingMailView) {
            if canSendEmails {
                MailView(isPresented: $isShowingMailView,
                         recipients: $emailRecipients,
                         subject: $emailSubject,
                         body: $emailBodyTemplate)
            } else {
                EmailRequiredView()
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
