//
//  DoubleExtension.swift
//  Dragula
//
//

import Foundation

extension Double {
    func toNormalizedResolutionValue() -> Double {
        let slope = (1995.0/1242850962)
        return self * slope + 75
    }
}
