//
//  CompleteFipeModel.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import Foundation

struct CompleteFipeModel: Codable {
    var Valor:String
    var Marca:String
    var Modelo:String
    var AnoModelo:Int
    var Combustivel:String
    var CodigoFipe:String
    var MesReferencia:String
    var DataConsulta:String
}

struct FipeResumidaModel {
    let valor: Double
    let mesReferencia: String
}
