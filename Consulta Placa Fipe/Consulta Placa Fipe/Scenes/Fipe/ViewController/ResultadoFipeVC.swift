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
    
    //Chart
    @IBOutlet weak var chartView: UIView!
    
    // MARK: - Properties
    var resultFipe: [CompleteFipeModel]?
    
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
        
        setupFipe()
    }
    
    // MARK: - Methods
    func setupFipe() {
        guard let resultado = resultFipe else { return }
        let mesAtual = UserDefaults.standard.getMonthReference()
        let dateFormat = "MMMM/yyyy"  // Define o formato esperado das datas

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")  // Define o local para "pt_BR" para tratar o mês em português
        dateFormatter.dateFormat = dateFormat
        
        for item in resultado {
            let dataA = item.MesReferencia.replacingOccurrences(of: "de", with: "").replacingOccurrences(of: " ", with: "")
            let dataB = mesAtual.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "")
                
            if dataA == dataB {
                print("As variáveis representam o mesmo mês e ano.")
                self.brandLabel.attributedText = NSMutableAttributedString().bold("Marca: ").normal("\(item.Marca)")
                self.modelLabel.attributedText = NSMutableAttributedString().bold("Modelo: ").normal("\(item.Modelo)")
                self.yearLabel.attributedText = NSMutableAttributedString().bold("Ano/Modelo: ").normal("\(item.AnoModelo)")
                self.fuelLabel.attributedText = NSMutableAttributedString().bold("Combustível: ").normal("\(item.Combustivel)")
                self.fipeCodeLabel.attributedText = NSMutableAttributedString().bold("Código FIPE: ").normal("\(item.CodigoFipe)")
                self.refereceMonthLabel.attributedText = NSMutableAttributedString().bold("Mês de Referência: ").normal("\(item.MesReferencia)")
                self.dateQueryLabel.attributedText = NSMutableAttributedString().bold(item.DataConsulta)
                self.priceLabel.text = item.Valor
                return
            } else {
                print("As variáveis representam meses e/ou anos diferentes.")
            }
        }
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
