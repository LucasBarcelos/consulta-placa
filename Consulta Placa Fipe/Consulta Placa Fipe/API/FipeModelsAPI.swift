//
//  FipeModelsAPI.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation

protocol FipeModelsAPIProtocol {
    func success(models: VehicleModelsModel)
    func error(error: Error)
}

class FipeModelsAPI {
    
    // Properties
    var delegate: FipeModelsAPIProtocol?
    
    // Methods
    public func fetchModels(vehicleType: Int, brandCode: Int) {
        
        guard let url = URL(string: BaseURLServices.fipeModels) else { return }
        let parameters: [String: Any] = ["codigoTabelaReferencia": UserDefaults.standard.getCodeReference(), "codigoTipoVeiculo": vehicleType, "codigoMarca": brandCode]
        let parameterJson = try? JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = parameterJson
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) {(data, response, error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode(VehicleModelsModel.self, from: data)
                    self.delegate?.success(models: json)
                } catch {
                    self.delegate?.error(error: error)
                    print("Error ao carregar Marcas: \(error)")
                }
            }
        }.resume()
    }
}
