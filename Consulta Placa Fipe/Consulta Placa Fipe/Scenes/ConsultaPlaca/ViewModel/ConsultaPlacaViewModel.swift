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
            
        // Filtrar os itens com o maior score
        let maxScore = dadosFipe.max(by: { $0.score < $1.score })?.score ?? 0
        dadosFipe = dadosFipe.filter { $0.score == maxScore }
        
        // Verificar se há itens com o mesmo score e filtrar com base no combustível
        if dadosFipe.count > 1 {
            let combustivel = plate.extra.combustivel
            dadosFipe = dadosFipe.filter { $0.combustivel == combustivel }
        }
        
        // Atualizar a lista no objeto plate
        result.fipe?.dados = dadosFipe
        
        // Chamar o delegate com o resultado final
        self.delegate?.successGoToResult(result: result)
    }
    
    func error(error: Error) {
        // TODO: ALERT PARA A PLACA
        print("Error ao carregar placa - View Model")
        self.delegate?.erroFetch(message: String(error.localizedDescription))
    }
}
