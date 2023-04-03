//
//  VehicleModelsModel.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import Foundation

struct VehicleModelsModel: Codable {
    var modelos:[Modelo]
    
    enum CodingKeys: String, CodingKey {
        case modelos = "Modelos"
    }
}

struct Modelo: Codable {
    let label: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case label = "Label"
        case value = "Value"
    }
}
