//
//  MailView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI
import UIKit
import MessageUI

// MARK: - Mail View Coordinator

/**
 The coordinator class is responsible for managing the `MFMailComposeViewController` events and dismissing the view controller once the mail is composed or cancelled.

 - Parameters:
    - isPresented: A binding to a Boolean value that indicates whether the mail compose view controller is presented.
 */
class MailViewCoordinator: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    /**
     Called when the user finishes with the mail compose view controller.
     
     - Parameters:
        - controller: The `MFMailComposeViewController` instance.
        - result: The result of the mail compose action.
        - error: An optional error if one occurred during the mail compose action.
     */
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        isPresented = false
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Mail View

/**
 A SwiftUI view that presents a `MFMailComposeViewController` for composing and sending an email.

 - Parameters:
    - isPresented: A binding to a Boolean value that indicates whether the mail compose view controller is presented.
    - recipients: An array of recipient email addresses.
    - subject: The subject of the email.
    - body: The body text of the email.
 */
struct MailView: UIViewControllerRepresentable {
    /// A binding to a Boolean value that indicates whether the mail compose view controller is presented.
    @Binding var isPresented: Bool
    /// An array of recipient email addresses.
    var recipients: [String]
    /// The subject of the email.
    var subject: String
    /// The body text of the email.
    var body: String
    
    /**
     Creates the coordinator instance for managing the mail compose view controller.
     
     - Returns: A `MailViewCoordinator` instance.
     */
    func makeCoordinator() -> MailViewCoordinator {
        return MailViewCoordinator(isPresented: $isPresented)
    }
    
    /**
     Creates the `MFMailComposeViewController` instance and configures it with the provided recipients, subject, and body.
     
     - Parameters:
        - context: The context of the view.
     
     - Returns: A configured `MFMailComposeViewController` instance.
     */
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        mailComposeVC.setToRecipients(recipients)
        mailComposeVC.setSubject(subject)
        mailComposeVC.setMessageBody(body, isHTML: false)
        return mailComposeVC
    }
    
    /**
     Updates the `MFMailComposeViewController` instance. Not needed in this case.
     
     - Parameters:
        - uiViewController: The `MFMailComposeViewController` instance.
        - context: The context of the view.
     */
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No update needed
    }
    
    /**
     Dismantles the `MFMailComposeViewController` instance.
     
     - Parameters:
        - uiViewController: The `MFMailComposeViewController` instance.
        - coordinator: The coordinator instance.
     */
    static func dismantleUIViewController(_ uiViewController: MFMailComposeViewController, coordinator: Self.Coordinator) {
        uiViewController.dismiss(animated: true, completion: nil)
    }
}
