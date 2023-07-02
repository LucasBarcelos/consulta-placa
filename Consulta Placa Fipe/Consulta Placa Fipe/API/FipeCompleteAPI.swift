//
//  FipeCompleteAPI.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation

protocol FipeCompleteAPIProtocol {
    func success(result: [CompleteFipeModel])
    func error(error: Error)
}

class FipeCompleteAPI {
    
    // Properties
    var delegate: FipeCompleteAPIProtocol?
    
    // Methods
    public func fetchComplete(mesReferencia: Int, vehicleType: Int, brandCode: Int, modelCode: Int, yearFuel: String, completion: @escaping (CompleteFipeModel?, Error?) -> Void) {
        
        guard let url = URL(string: BaseURLServices.fipeComplete) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        guard let last = yearFuel.last, let tipoCombustivel = Int(String(last)) else {
            completion(nil, NSError(domain: "Invalid fuel type", code: 0, userInfo: nil))
            return
        }

        guard let anoModelo = Int(yearFuel.prefix(4)) else {
            completion(nil, NSError(domain: "Invalid year model", code: 0, userInfo: nil))
            return
        }
        
        let parameters: [String: Any] = ["codigoTabelaReferencia": mesReferencia,
                                         "codigoTipoVeiculo": vehicleType,
                                         "codigoMarca": brandCode,
                                         "codigoModelo": modelCode,
                                         "ano": yearFuel,
                                         "codigoTipoCombustivel": tipoCombustivel,
                                         "anoModelo": anoModelo,
                                         "tipoConsulta": "tradicional"]
        
        guard let parameterJson = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion(nil, NSError(domain: "Serialization parameters error", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = parameterJson
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) {(data, response, error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode(CompleteFipeModel.self, from: data)
                    completion(json, nil)
                } catch {
                    print("Error ao carregar Ano / Modelo: \(error)")
                    completion(nil, error)
                }
            } else if let error = error {
                completion(nil, error)
                print("Error ao carregar Ano / Modelo: \(error)")
            }
        }.resume()
    }
    
    func fetchLastMonths(months: [ReferenceMonthModel], vehicleType: Int, brandCode: Int, modelCode: Int, yearFuel: String, completion: @escaping ([CompleteFipeModel], Error?) -> Void) {
        
        var result: [CompleteFipeModel] = []
        var errors: [Error] = []
        
        let dispatchGroup = DispatchGroup()
        
        for month in months {
            dispatchGroup.enter()
            
            fetchComplete(mesReferencia: month.Codigo, vehicleType: vehicleType, brandCode: brandCode, modelCode: modelCode, yearFuel: yearFuel) { (resultModel, error) in
                if let resultModel = resultModel {
                    result.append(resultModel)
                }
                if let error = error {
                    errors.append(error)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !errors.isEmpty || !result.isEmpty {
                completion(result, nil)
                self.delegate?.success(result: result)
            } else {
                completion(result, errors.first)
                guard let error = errors.first else { return }
                self.delegate?.error(error: error)
            }
        }
    }
}
