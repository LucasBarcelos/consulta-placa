//
//  CompleteFipeViewModel.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import Foundation
import UIKit

protocol CompleteFipeViewModelProtocol: AnyObject {
    func successGoToResult(result: CompleteFipeModel?)
    func erroFetch(message: String)
}

class CompleteFipeViewModel: FipeCompleteAPIProtocol {
    
    weak var delegate:CompleteFipeViewModelProtocol?
    let serviceAPI:FipeCompleteAPI?
    
    init(serviceAPI: FipeCompleteAPI) {
        self.serviceAPI = serviceAPI
        self.serviceAPI?.delegate = self
    }
    
    func delegate(delegate:CompleteFipeViewModelProtocol?){
        self.delegate = delegate
    }
    
    func success(result: CompleteFipeModel) {
        self.delegate?.successGoToResult(result: result)
    }
    
    func error(error: Error) {
        // TODO: ALERT PARA A Fipe Completa
        print("Error ao carregar Fipe Completa - View Model")
        self.delegate?.erroFetch(message: String(error.localizedDescription))
    }
}

