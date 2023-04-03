//
//  FipeCompleteAPI.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation

protocol FipeCompleteAPIProtocol {
    func success(result: CompleteFipeModel)
    func error(error: Error)
}

class FipeCompleteAPI {
    
    // Properties
    var delegate: FipeCompleteAPIProtocol?
    
    // Methods
    public func fetchComplete(vehicleType: Int, brandCode: Int, modelCode: Int, yearFuel: String) {
        
        guard let url = URL(string: BaseURLServices.fipeComplete) else { return }
        
        guard let last = yearFuel.last,
              let tipoCombustivel = Int(String(last)) else { return }

        guard let anoModelo = Int(yearFuel.prefix(4)) else { return }
        
        let parameters: [String: Any] = ["codigoTabelaReferencia": UserDefaults.standard.getCodeReference(),
                                         "codigoTipoVeiculo": vehicleType,
                                         "codigoMarca": brandCode,
                                         "codigoModelo": modelCode,
                                         "ano": yearFuel,
                                         "codigoTipoCombustivel": tipoCombustivel,
                                         "anoModelo": anoModelo,
                                         "tipoConsulta": "tradicional"]
        
        let parameterJson = try? JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = parameterJson
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) {(data, response, error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode(CompleteFipeModel.self, from: data)
                    self.delegate?.success(result: json)
                } catch {
                    self.delegate?.error(error: error)
                    print("Error ao carregar Ano / Modelo: \(error)")
                }
            }
        }.resume()
    }
}
