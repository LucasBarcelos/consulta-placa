//
//  NSMutableAttributedStringExtension.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 18/01/23.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [.font : boldSystemFont()]
    
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [.font : normalSystemFont()]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normalSystemFont() -> UIFont {
        switch UIDevice().screenType {
        case .small:
            return UIFont.systemFont(ofSize: 16)
        case .medium:
            return UIFont.systemFont(ofSize: 16)
        case .large:
            return UIFont.systemFont(ofSize: 20)
        }
    }
    
    func boldSystemFont() -> UIFont {
        switch UIDevice().screenType {
        case .small:
            return UIFont.boldSystemFont(ofSize: 16)
        case .medium:
            return UIFont.boldSystemFont(ofSize: 16)
        case .large:
            return UIFont.boldSystemFont(ofSize: 20)
        }
    }
}
