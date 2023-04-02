//
//  UtilsPreference.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation

enum UserDefaultsKeys : String {
    case month
    case code
}

extension UserDefaults {
    
    func setMonthReference(value: String) {
        set(value, forKey: UserDefaultsKeys.month.rawValue)
    }
    
    func setCodeReference(value: Int) {
        set(value, forKey: UserDefaultsKeys.code.rawValue)
    }
    
    func getMonthReference() -> String {
        return string(forKey: UserDefaultsKeys.month.rawValue) ?? ""
    }
    
    func getCodeReference() -> Int {
        return integer(forKey: UserDefaultsKeys.code.rawValue)
    }
    
}
