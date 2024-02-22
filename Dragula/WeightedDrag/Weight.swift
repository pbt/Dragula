//
//  Weight.swift
//  Dragula
//
//

import Foundation
import PointerKit

class Weight {
    struct DeviceSettings {
        var pointerResolution: Double
        var pointerAcceleration: Double
    }
    
    static let shared = Weight()
    var manager: PointerDeviceManager
    var initialSettings = [Int:DeviceSettings]()
    var applyAccel = true
    
    init() {
        manager = PointerDeviceManager()
        manager.startObservation()
        // TODO this assumes you don't plug in new devices
        for device in manager.devices {
            initialSettings[device.hashValue] = DeviceSettings(pointerResolution: device.pointerResolution ?? 0.0, pointerAcceleration: device.pointerAcceleration ?? 0.0)
        }
    }
}

extension Weight {
    static func apply(weight: Double) {
        for device in Weight.shared.manager.devices {
            device.pointerAcceleration = 1/weight * 20
            device.pointerResolution = weight
        }
    }
    static func takeOff() {
        for device in Weight.shared.manager.devices {
            let settings = Weight.shared.initialSettings[device.hashValue]
            device.pointerResolution = settings?.pointerResolution
            device.pointerAcceleration = settings?.pointerAcceleration
        }
    }
}
