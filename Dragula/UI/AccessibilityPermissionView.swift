// MIT License
// Copyright (c) 2021-2024 LinearMouse

import os.log
import SwiftUI

struct AccessibilityPermissionView: View {
    @State private var showAlert = false

    private static let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AccessibilityPermissionView")

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "accessibility.fill")
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 15) {
                    
                    Text("Dragula needs Accessibility permissions")
                        .font(.headline)
                    Text(
                        "You need to grant Accessibility permissions in System Settings > Security & Privacy > Accessibility."
                    )
                }
                .padding(.horizontal)
                
            }

            Spacer()

            HStack {
                Button("Open Accessibility") {
                    openAccessibility()
                }
            }
        }.padding()
    }

    func openAccessibility() {
        AccessibilityPermission.shared.prompt()
    }
}

struct AccessibilityPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityPermissionView()
    }
}
