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
    
    private var consultaPlaca: ConsultaPlacaModel?
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
        self.consultaPlaca = plate
        self.delegate?.successGoToResult(result: plate)
    }
    
    func error(error: Error) {
        // TODO: ALERT PARA A PLACA
        print("Error ao carregar placa - View Model")
        self.delegate?.erroFetch(message: String(error.localizedDescription))
    }
}
