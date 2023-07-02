//
//  ConsultaPlacaViewModel.swift
//  ConsultaPlacaFipe
//
//  Created by Lucas Barcelos on 30/12/22.
//

import Foundation
import UIKit

protocol ConsultaPlacaViewModelProtocol: AnyObject {
    func successGoToResult(result: ConsultaPlacaModel?)
    func erroFetch(message: String)
}

class ConsultaPlacaViewModel: ConsultaPlacaServiceAPIProtocol {
    
    weak var delegate:ConsultaPlacaViewModelProtocol?
    let serviceAPI:ConsultaPlacaServiceAPI?
    
    init(serviceAPI: ConsultaPlacaServiceAPI) {
        self.serviceAPI = serviceAPI
        self.serviceAPI?.delegate = self
    }
    
    func delegate(delegate:ConsultaPlacaViewModelProtocol?){
        self.delegate = delegate
    }
    
    func success(plate: ConsultaPlacaModel) {
        var result = plate
        guard var dadosFipe = plate.fipe?.dados else { return }
        
        // Ordenar os itens em ordem decrescente de score
        dadosFipe.sort(by: { $0.score > $1.score })
        
        // Filtrar os cinco primeiros itens com maior score
        let topThreeItems = Array(dadosFipe.prefix(5))
               
        // Atualizar a lista no objeto plate
        result.fipe?.dados = topThreeItems
        
        // Chamar o delegate com o resultado final
        self.delegate?.successGoToResult(result: result)
    }
    
    func error(error: Error) {
        // TODO: ALERT PARA A PLACA
        print("Error ao carregar placa - View Model")
        self.delegate?.erroFetch(message: String(error.localizedDescription))
    }
}
