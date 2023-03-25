//
//  UIDeviceExtension.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 14/01/23.
//

import Foundation
import UIKit

public extension UIDevice {
    
    enum ScreenType: String {
        case small
        case medium
        case large
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .small
        case 1334:
            return .medium
        case 2340:
            return .medium
        case 2532:
            return .medium
        case 2436:
            return .large
        case 2778:
            return .large
        default:
            return .large
        }
    }
}
