//
//  ReferenceMothFipeAPI.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import Foundation

class FipeReferenceMonthAPI {
    
    // Methods
    public func fetchReferenceMonth() {
        
        guard let url = URL(string: BaseURLServices.fipeMonthReference) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        session.dataTask(with: request) {(data, response, error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode([ReferenceMonthModel].self, from: data)
                    UserDefaults.standard.setMonthReference(value: json.first?.Mes ?? "")
                    UserDefaults.standard.setCodeReference(value: json.first?.Codigo ?? 0)
                } catch {
                    print("Error ao carregar mês de referência")
                }
            }
        }.resume()
    }
}
