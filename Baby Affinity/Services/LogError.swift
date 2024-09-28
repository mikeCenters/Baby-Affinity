//
//  LogError.swift
//  Baby Affinity
//
//  Created by Mike Centers on 8/13/24.
//

import Foundation
import os

/// Logs an error message to the OS logging system.
///
/// - Parameter message: The error message to log.
/// - Note: This function uses the `os.Logger` class to log error messages under the "Error" category.
///         If the app's bundle identifier is available, it is used as the subsystem; otherwise, a default
///         value of "com.yourapp" is used.
//func logError(_ message: String) {
//    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp", category: "Error")
//    logger.error("\(message)")
//}
