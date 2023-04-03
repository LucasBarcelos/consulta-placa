//
//  BaseURLServices.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

class BaseURLServices {
    
    //Consulta Placa
    static let fetchPlate: String = "https://wdapi.com.br/placas/PLATE/ad263bf1ec2a45149fc49b8a1eb877e5"
    
    //Tabela FIPE
    static let fipeMonthReference: String = "http://veiculos.fipe.org.br/api/veiculos/ConsultarTabelaDeReferencia"
    static let fipeBrands: String = "http://veiculos.fipe.org.br/api/veiculos/ConsultarMarcas"
    static let fipeModels: String = "http://veiculos.fipe.org.br/api/veiculos/ConsultarModelos"
    static let fipeYearModel: String = "http://veiculos.fipe.org.br/api/veiculos/ConsultarAnoModelo"
    static let fipeComplete: String = "http://veiculos.fipe.org.br/api/veiculos/ConsultarValorComTodosParametros"
}
