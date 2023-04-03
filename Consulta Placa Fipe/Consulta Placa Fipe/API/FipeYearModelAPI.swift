//
//  FipeYearModelAPI.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation

protocol FipeYearModelAPIProtocol {
    func success(yearModel: [GenericFipeModel])
    func error(error: Error)
}

class FipeYearModelAPI {
    
    // Properties
    var delegate: FipeYearModelAPIProtocol?
    
    // Methods
    public func fetchYearModel(vehicleType: Int, brandCode: Int, modelCode: Int) {
        
        guard let url = URL(string: BaseURLServices.fipeYearModel) else { return }
        let parameters: [String: Any] = ["codigoTabelaReferencia": UserDefaults.standard.getCodeReference(), "codigoTipoVeiculo": vehicleType, "codigoMarca": brandCode, "codigoModelo": modelCode]
        let parameterJson = try? JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = parameterJson
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) {(data, response, error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode([GenericFipeModel].self, from: data)
                    self.delegate?.success(yearModel: json)
                } catch {
                    self.delegate?.error(error: error)
                    print("Error ao carregar Ano / Modelo: \(error)")
                }
            }
        }.resume()
    }
}
