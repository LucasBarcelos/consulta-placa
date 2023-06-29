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
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // MARK: - Properties
    var resultFipe: CompleteFipeModel?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            if GoogleAdsManager.successCounter >= 2 {
                if let interstitial = GoogleAdsManager.shared.interstitial {
                    GoogleAdsManager.successCounter = 0
                    interstitial.present(fromRootViewController: self)
                    print("Anúncio FIPE - intersticial exibido com sucesso!")
                } else {
                    print("Anúncio FIPE - intersticial não está pronto ainda.")
                }
            }
        }

        guard let resultado = resultFipe else { return }
        self.brandLabel.attributedText = NSMutableAttributedString().bold("Marca: ").normal("\(resultado.Marca)")
        self.modelLabel.attributedText = NSMutableAttributedString().bold("Modelo: ").normal("\(resultado.Modelo)")
        self.yearLabel.attributedText = NSMutableAttributedString().bold("Ano/Modelo: ").normal("\(resultado.AnoModelo)")
        self.fuelLabel.attributedText = NSMutableAttributedString().bold("Combustível: ").normal("\(resultado.Combustivel)")
        self.fipeCodeLabel.attributedText = NSMutableAttributedString().bold("Código FIPE: ").normal("\(resultado.CodigoFipe)")
        self.refereceMonthLabel.attributedText = NSMutableAttributedString().bold("Mês de Referência: ").normal("\(resultado.MesReferencia)")
        self.dateQueryLabel.attributedText = NSMutableAttributedString().bold(resultado.DataConsulta)
        self.priceLabel.text = resultado.Valor
    }
    

    // MARK: - Actions
    @IBAction func newQueryButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {

        let startPoint = CGPoint(x: brandLabel.frame.origin.x, y: brandLabel.frame.origin.y - 20)
        let endPoint = CGPoint(x: dateQueryLabel.frame.maxX, y: dateQueryLabel.frame.maxY + 20)
        
        // Determine as dimensões do print com base nas posições das labels
        let printWidth = endPoint.x - startPoint.x
        let printHeight = endPoint.y - startPoint.y
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: printWidth, height: printHeight), false, 0.0)
        
        if let context = UIGraphicsGetCurrentContext() {
            // Translate o contexto para a posição correta da primeira label
            context.translateBy(x: -startPoint.x, y: -startPoint.y)
            
            // Renderize a view hierarquia no contexto
            view.layer.render(in: context)
            
            // Capture a imagem renderizada
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            // Salve ou utilize a imagem capturada conforme necessário
            if let image = capturedImage {
                if let img = capturedImage {
                    let objectsToShare = [img] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        }
    }
}
