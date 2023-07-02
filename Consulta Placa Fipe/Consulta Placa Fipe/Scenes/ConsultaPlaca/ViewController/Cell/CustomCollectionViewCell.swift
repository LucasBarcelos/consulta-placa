//
//  CustomCollectionViewCell.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/07/23.
//

import UIKit

protocol CustomCollectionViewCellProtocol: AnyObject {
    func displayInformations(marca: String, modelo: String, ano: String, combustivel: String, referencia: String, codigo: String, valor: String)
}

class CustomCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var fipeMarcaLabel: UILabel!
    @IBOutlet weak var fipeModeloLabel: UILabel!
    @IBOutlet weak var fipeAnoLabel: UILabel!
    @IBOutlet weak var fipeCombustivelLabel: UILabel!
    @IBOutlet weak var fipeReferenciaLabel: UILabel!
    @IBOutlet weak var fipeCodigoLabel: UILabel!
    @IBOutlet weak var fipeValorLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 2, height: 4)
        self.layer.shadowOpacity = 0.30
        self.layer.masksToBounds = false
    }
}

// MARK: - Extension - ListCellPresenter
extension CustomCollectionViewCell: CustomCollectionViewCellProtocol {
    func displayInformations(marca: String, modelo: String, ano: String, combustivel: String, referencia: String, codigo: String, valor: String) {
        
        fipeMarcaLabel.attributedText = NSMutableAttributedString().boldCustom("Marca: ").normalCustom("\(marca)")
        fipeModeloLabel.attributedText = NSMutableAttributedString().boldCustom("Modelo: ").normalCustom("\(modelo)")
        fipeAnoLabel.attributedText = NSMutableAttributedString().boldCustom("Ano: ").normalCustom("\(ano)")
        fipeCombustivelLabel.attributedText = NSMutableAttributedString().boldCustom("Combustível: ").normalCustom("\(combustivel)")
        fipeReferenciaLabel.attributedText = NSMutableAttributedString().boldCustom("Referência: ").normalCustom("\(referencia)")
        fipeCodigoLabel.attributedText = NSMutableAttributedString().boldCustom("Codigo: ").normalCustom("\(codigo)")
        fipeValorLabel.text = "\(valor)"
    }
}
