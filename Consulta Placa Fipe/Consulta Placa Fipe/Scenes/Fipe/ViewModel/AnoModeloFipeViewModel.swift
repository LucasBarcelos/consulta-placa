//
//  AnoModeloFipeViewModel.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation
import UIKit

protocol AnoModeloFipeViewModelProtocol: AnyObject {
    func successGoToResult(yearModel: [GenericFipeModel]?)
    func erroFetch(message: String)
}

class AnoModeloFipeViewModel: FipeYearModelAPIProtocol {
    
    weak var delegate:AnoModeloFipeViewModelProtocol?
    let serviceAPI:FipeYearModelAPI?
    
    init(serviceAPI: FipeYearModelAPI) {
        self.serviceAPI = serviceAPI
        self.serviceAPI?.delegate = self
    }
    
    func delegate(delegate:AnoModeloFipeViewModelProtocol?){
        self.delegate = delegate
    }
    
    func success(yearModel: [GenericFipeModel]) {
        self.delegate?.successGoToResult(yearModel: yearModel)
    }
    
    func error(error: Error) {
        // TODO: ALERT PARA A Ano / Modelo
        print("Error ao carregar Ano / Modelo - View Model")
        self.delegate?.erroFetch(message: String(error.localizedDescription))
    }
}
