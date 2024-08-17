//
//  SendEmailButton.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/17/24.
//

import SwiftUI
import MessageUI

/**
 A SwiftUI view that presents a button to send an email.

 The `SendEmailButton` view displays a button that, when tapped, presents a mail compose view if the device can send emails, or an alternative view indicating that email functionality is required. It uses `MFMailComposeViewController` under the hood to present the mail compose interface.

 - Parameters:
    - emailRecipients: An array of email addresses to pre-populate the recipients field.
    - emailSubject: A string to pre-populate the subject field of the email.
    - buttonText: The text to display on the button.
 
 - Usage:
    ```swift
    SendEmailButton(emailRecipients: ["example@example.com"],
                    emailSubject: "Feedback",
                    buttonText: "Send Feedback")
    ```

 - Note:
    Ensure that the device has an email account set up and that the `MessageUI` framework is imported.
 */
struct SendEmailButton: View {
    
    // MARK: - Properties
    
    /// Array of email addresses to pre-populate the recipients field
    let emailRecipients: [String]
    
    /// Subject to pre-populate the subject field of the email
    let emailSubject: String
    
    /// Text to display on the button
    let buttonText: String
    
    
    // MARK: - Controls and Constants
    
    /// State variable to track the presentation of the mail view
    @State private var isShowingMailView = false
    
    /// Computed property to check if the device can send emails
    private var canSendEmails: Bool { MFMailComposeViewController.canSendMail() }
    
    /// Template for the email body, including app version
    let emailBodyTemplate: String = """
    \n\n
    =============
    App Version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unable to get App Version.")
    =============
    """
    
    
    // MARK: - Body
    
    var body: some View {
        Button {
            isShowingMailView.toggle()
        } label: {
            Text(buttonText)
                .bold()
        }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $isShowingMailView) {
            if canSendEmails {
                MailView(isPresented: $isShowingMailView,
                         recipients: emailRecipients,
                         subject: emailSubject,
                         body: emailBodyTemplate)
            } else {
                EmailRequiredView()
            }
        }
    }
}


#if DEBUG

// MARK: - Previews

#Preview("Send Email Button") {
    SendEmailButton(emailRecipients: ["someone@email.com"],
                    emailSubject: "Subject Text",
                    buttonText: "Send Email")
}

#endif
