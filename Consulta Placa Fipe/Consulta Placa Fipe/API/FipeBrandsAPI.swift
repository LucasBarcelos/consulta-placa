//
//  FipeBrandsAPI.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation

protocol FipeBrandsAPIProtocol {
    func success(brands: [GenericFipeModel])
    func error(error: Error)
}

class FipeBrandsAPI {
    
    // Properties
    var delegate: FipeBrandsAPIProtocol?
    
    // Methods
    public func fetchBrands(vehicleType: Int) {
        
        guard let url = URL(string: BaseURLServices.fipeBrands) else { return }
        let parameters: [String: Any] = ["codigoTabelaReferencia": UserDefaults.standard.getCodeReference(), "codigoTipoVeiculo": vehicleType]
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
                    self.delegate?.success(brands: json)
                } catch {
                    self.delegate?.error(error: error)
                    print("Error ao carregar Marcas: \(error)")
                }
            }
        }.resume()
    }
}
