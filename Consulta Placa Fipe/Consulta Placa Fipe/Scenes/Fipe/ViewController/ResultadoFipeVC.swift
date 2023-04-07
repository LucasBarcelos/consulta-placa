//
//  ResultadoFipeVC.swift
//  Consulta Placa Fipe
//
//  Created by Lucas Barcelos on 02/04/23.
//

import UIKit

class ResultadoFipeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var fuelLabel: UILabel!
    @IBOutlet weak var fipeCodeLabel: UILabel!
    @IBOutlet weak var dateQueryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var refereceMonthLabel: UILabel!
    @IBOutlet weak var newQueryButton: UIButton!
    
    // MARK: - Properties
    var resultFipe: CompleteFipeModel?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let resultado = resultFipe else { return }
        self.brandLabel.attributedText = NSMutableAttributedString().bold("Marca: ").normal("\(resultado.Marca)")
        self.modelLabel.attributedText = NSMutableAttributedString().bold("Modelo: ").normal("\(resultado.Modelo)")
        self.yearLabel.attributedText = NSMutableAttributedString().bold("Ano/Modelo: ").normal("\(resultado.AnoModelo)")
        self.fuelLabel.attributedText = NSMutableAttributedString().bold("Combustível: ").normal("\(resultado.Combustivel)")
        self.fipeCodeLabel.attributedText = NSMutableAttributedString().bold("Código FIPE: ").normal("\(resultado.CodigoFipe)")
        self.dateQueryLabel.text = resultado.DataConsulta
        self.priceLabel.text = resultado.Valor
        self.refereceMonthLabel.attributedText = NSMutableAttributedString().bold("Mês de Referência: ").normal("\(resultado.MesReferencia)")
    }
    

    // MARK: - Actions
    @IBAction func newQueryButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
