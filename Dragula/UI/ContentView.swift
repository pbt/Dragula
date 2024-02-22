//
//  ContentView.swift
//  Dragula
//
//

import SwiftUI

struct ContentView: View {
    @State private var shouldPlaySound = false
    @State private var shouldDragWindow = false
    @State private var applyAccel = false
    
    @StateObject private var accessibilityPermission = AccessibilityPermission.shared

    var body: some View {
        if (accessibilityPermission.enabled) {
            HStack() {
                VStack() {
                    Image(.dragula).resizable().scaledToFit()
                    Text("Dragula").font(.largeTitle)
                }.padding()
                    .frame(width: 200, height: 400).background(in: Rectangle())
                Form {
                    Section(header: Text("Reset").font(.headline)) {
                        Button("Reset All Drag Behavior") {
                            Weight.takeOff()
                        }.keyboardShortcut(KeyEquivalent("r"), modifiers: [.command, .shift])
                        Text("Press this button or quit the app to reset drag behavior.").font(.callout)
                    }
                    Spacer()
                    Section(header: Text("Options)").font(.headline)) {
                                Toggle(isOn: $applyAccel) {
                                    Text("Apply pointer acceleration")
                                }.onChange(of: applyAccel) { _, applyAccel in
                                    Weight.shared.applyAccel = applyAccel
                                }
                    }
                    Section(header: Text("Bonuses (Buggy)").font(.headline)) {
                                Toggle(isOn: $shouldDragWindow) {
                                    Text("Add drag behavior to Finder windows")
                                }.onChange(of: shouldDragWindow) { _, shouldDragWindow in
                                    EventTap.shared?.windowDrag = shouldDragWindow
                                }
                                Toggle(isOn: $shouldPlaySound) {
                                    Text("Sound effects")
                                }.onChange(of: shouldPlaySound) { _, shouldPlaySound in
                                    EventTap.shared?.shouldPlaySound = shouldPlaySound
                                }
                    }
                    
                } .padding()
                    .frame(width: 450, height: 200)
            }
           
        } else {
            HStack() {
                    Image(systemName:"accessibility.fill").renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                
                    Text("Waiting for accessibility settings...").font(.title)
            }
            .padding()
            .frame(width: 450, height: 200)
        }
    }
}

#Preview {
    ContentView()
}
