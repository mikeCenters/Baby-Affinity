//
//  MailView.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/16/24.
//

import SwiftUI
import UIKit
import MessageUI

// MARK: - Coordinator

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


// MARK: - View

/**
 A SwiftUI view that presents a `MFMailComposeViewController` for composing and sending an email.

 - Parameters:
    - isPresented: A binding to a Boolean value that indicates whether the mail compose view controller is presented.
    - recipients: A binding to an array of recipient email addresses.
    - subject: A binding to the subject of the email.
    - body: A binding to the body text of the email.
 */
struct MailView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var recipients: [String]
    @Binding var subject: String
    @Binding var body: String
    
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
