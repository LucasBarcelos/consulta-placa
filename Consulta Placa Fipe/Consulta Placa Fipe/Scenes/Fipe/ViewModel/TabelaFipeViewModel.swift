//
//  MarcasFipeViewModel.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 01/04/23.
//

import Foundation
import UIKit

protocol TabelaFipeViewModelProtocol: AnyObject {
    func successGoToResult(brands: [GenericFipeModel]?)
    func erroFetch(message: String)
}

class TabelaFipeViewModel: FipeBrandsAPIProtocol {
    
    weak var delegate:TabelaFipeViewModelProtocol?
    let serviceAPI:FipeBrandsAPI?
    
    init(serviceAPI: FipeBrandsAPI) {
        self.serviceAPI = serviceAPI
        self.serviceAPI?.delegate = self
    }
    
    func delegate(delegate:TabelaFipeViewModelProtocol?){
        self.delegate = delegate
    }
    
    func success(brands: [GenericFipeModel]) {
        self.delegate?.successGoToResult(brands: brands)
    }
    
    func error(error: Error) {
        // TODO: ALERT PARA A Marcas
        print("Error ao carregar Marcas - View Model")
        self.delegate?.erroFetch(message: String(error.localizedDescription))
    }
}
