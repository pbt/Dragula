//
//  AppDelegate.swift
//  Dragula
//
//

import Foundation
import SwiftUI
import PointerKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        guard AccessibilityPermission.shared.enabled else {
            AccessibilityPermissionWindow.shared.bringToFront()
            return
        }
        EventTap.shared = EventTap()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Weight.takeOff()
        EventTap.shared?.done()
    }
}
