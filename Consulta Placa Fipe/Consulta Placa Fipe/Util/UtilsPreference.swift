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
    case historic
}

extension UserDefaults {
    
    func setMonthReference(value: String) {
        set(value, forKey: UserDefaultsKeys.month.rawValue)
    }
    
    func setCodeReference(value: Int) {
        set(value, forKey: UserDefaultsKeys.code.rawValue)
    }
    
    func setHistoricReference(value: [ReferenceMonthModel]) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(value) {
            set(encodedData, forKey: UserDefaultsKeys.historic.rawValue)
        }
    }
    
    func getMonthReference() -> String {
        return string(forKey: UserDefaultsKeys.month.rawValue) ?? ""
    }
    
    func getCodeReference() -> Int {
        return integer(forKey: UserDefaultsKeys.code.rawValue)
    }
    
    func getHistoricReference() -> [ReferenceMonthModel] {
        if let data = data(forKey: UserDefaultsKeys.historic.rawValue) {
            let decoder = JSONDecoder()
            if let historic = try? decoder.decode([ReferenceMonthModel].self, from: data) {
                return historic
            }
        }
        return []
    }
}
