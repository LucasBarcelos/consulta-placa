//
//  NSMutableAttributedStringExtension.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 18/01/23.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 20 }
    var boldFont:UIFont { return UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont.systemFont(ofSize: fontSize) }
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [.font : boldFont]
    
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [.font : normalFont]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
