//
//  MarcasFipeViewModel.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation
import UIKit

protocol MarcasFipeViewModelProtocol: AnyObject {
    func successGoToResult(models: VehicleModelsModel?)
    func erroFetch(message: String)
}

class MarcasFipeViewModel: FipeModelsAPIProtocol {
    
    weak var delegate:MarcasFipeViewModelProtocol?
    let serviceAPI:FipeModelsAPI?
    
    init(serviceAPI: FipeModelsAPI) {
        self.serviceAPI = serviceAPI
        self.serviceAPI?.delegate = self
    }
    
    func delegate(delegate:MarcasFipeViewModelProtocol?){
        self.delegate = delegate
    }
    
    func success(models: VehicleModelsModel) {
        self.delegate?.successGoToResult(models: models)
    }
    
    func error(error: Error) {
        // TODO: ALERT PARA A Modelos
        print("Error ao carregar Modelos - View Model")
        self.delegate?.erroFetch(message: String(error.localizedDescription))
    }
}
