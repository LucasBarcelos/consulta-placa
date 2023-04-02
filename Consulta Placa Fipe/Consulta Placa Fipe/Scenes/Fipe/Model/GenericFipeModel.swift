//
//  GenericFipeModel.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import Foundation

struct GenericFipeModel: Codable {
    let label, value: String

    enum CodingKeys: String, CodingKey {
        case label = "Label"
        case value = "Value"
    }
}
