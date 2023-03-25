//
//  ConsultaPlacaServiceAPI.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 10/01/23.
//

import Foundation

protocol ConsultaPlacaServiceAPIProtocol {
    func success(plate: ConsultaPlacaModel)
    func error(error: Error)
}

class ConsultaPlacaServiceAPI {
    
    // Properties
    var delegate: ConsultaPlacaServiceAPIProtocol?
    private var baseURL = "https://wdapi.com.br/placas/PLATE/ad263bf1ec2a45149fc49b8a1eb877e5"
    
    // Methods
    public func fetchPlate(plate: String) {
        
        let plateAux = plate.replacingOccurrences(of: "-", with: "")
        
        guard let url = URL(string: baseURL.replacingOccurrences(of: "PLATE", with: plateAux)) else { return }
        
        let request = URLSession.shared.dataTask(with: url){(data, response, error) in
            if let data = data {
                do {
                    let json = try JSONDecoder().decode(ConsultaPlacaModel.self, from: data)
                    self.delegate?.success(plate: json)
                } catch {
                    // TODO: ALERT PARA A PLACA
                    print("Error ao carregar placa - API")
                    self.delegate?.error(error: error)
                }
            }
        }
        request.resume()
    }
}
