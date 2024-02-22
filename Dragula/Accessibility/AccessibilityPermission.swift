// MIT License
// Copyright (c) 2021-2024 LinearMouse

import Foundation
import os.log
import SwiftUI
import Cocoa

class AccessibilityPermission: ObservableObject {
    static let shared = AccessibilityPermission()
    
    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AccessibilityPermission")
    @Published var enabled = AXIsProcessTrusted()

    func prompt() {
        AXIsProcessTrusted()
//        AXIsProcessTrustedWithOptions([
//            kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true
//        ] as CFDictionary)
        
        NSWorkspace.shared.open(URL(string:"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    func pollingUntilEnabled(completion: @escaping () -> Void) {
        guard enabled else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                os_log("Polling accessibility permission", log: self.log, type: .info)
                self.enabled = AXIsProcessTrusted()
                self.pollingUntilEnabled(completion: completion)
            }
            return
        }
        completion()
    }
}

enum AccessibilityPermissionError: Error {
    case resetError
}
