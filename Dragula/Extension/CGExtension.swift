//
//  CGExtension.swift
//  Dragula
//
//

import Foundation
import AppKit

extension CGPoint {
    var screenFlipped: CGPoint {
        .init(x: x, y: NSScreen.screens[0].frame.maxY - y)
    }
}

extension CGRect {
    var screenFlipped: CGRect {
        guard !isNull else {
            return self
        }
        return .init(origin: .init(x: origin.x, y: NSScreen.screens[0].frame.maxY - maxY), size: size)
    }

    var isLandscape: Bool { width > height }
}
