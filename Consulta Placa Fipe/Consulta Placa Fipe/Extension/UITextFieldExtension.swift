//
//  UITextFieldExtension.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 14/01/23.
//

import Foundation
import UIKit

extension UITextField {
    
    func adjustsFontSizeToFitDevice() {
        switch UIDevice().screenType {
        case .small:
            font = UIFont(name: "GL-Nummernschild-Eng", size: 70)
        case .medium:
            font = UIFont(name: "GL-Nummernschild-Eng", size: 84)
        case .large:
            font = UIFont(name: "GL-Nummernschild-Eng", size: 92)
        }
    }
}
