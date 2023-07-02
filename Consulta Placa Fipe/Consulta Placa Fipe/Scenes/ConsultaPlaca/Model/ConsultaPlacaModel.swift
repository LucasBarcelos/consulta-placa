//
//  ConsultaPlacaModel.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 06/01/23.
//

import Foundation

struct ConsultaPlacaModel: Codable {
    var ano:String
    var anoModelo:String
    var chassi:String
    var cor:String
    var data:String
    var logo:String
    var marca:String
    var marcaModelo:String
    var mensagemRetorno:String
    var modelo:String
    var municipio:String
    var origem:String
    var placa:String
    var placa_alternativa:String
    var situacao:String
    var uf:String
    var fipe:FipePlacaModel?
    var extra:Extra?
}


struct FipePlacaModel: Codable {
    var dados:[DadosFipePlaca]
}

struct Extra: Codable {
    var combustivel:String
}

struct DadosFipePlaca: Codable {
    let ano_modelo: String
    let codigo_fipe: String
    let combustivel: String
    let mes_referencia: String
    let score: Int
    let texto_marca: String
    let texto_modelo: String
    let texto_valor: String
}
